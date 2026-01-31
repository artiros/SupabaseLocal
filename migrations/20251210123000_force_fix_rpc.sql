CREATE OR REPLACE FUNCTION get_user_performance_metrics()
RETURNS TABLE (
  date date,
  ctl integer,
  atl integer,
  tsb integer
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  curr_user_id uuid;
  first_date date;
BEGIN
  curr_user_id := auth.uid();
  IF curr_user_id IS NULL THEN
    RETURN;
  END IF;

  SELECT MIN(start_date)::date INTO first_date FROM activities WHERE user_id = curr_user_id;

  -- Default to 90 days ago if no activities found, to show empty chart instead of nothing
  IF first_date IS NULL THEN
    first_date := CURRENT_DATE - INTERVAL '90 days';
  END IF;

  RETURN QUERY
  WITH RECURSIVE daily_tss AS (
    SELECT
      d::date as day,
      COALESCE(SUM(a.training_load), 0) as tss
    FROM
      generate_series(
        first_date,
        CURRENT_DATE,
        '1 day'::interval
      ) d
      LEFT JOIN activities a ON a.start_date::date = d::date AND a.user_id = curr_user_id
    GROUP BY d::date
  ),
  recursive_pmc AS (
    -- Anchor
    SELECT 
      day,
      tss::float as ctl_float,
      tss::float as atl_float
    FROM daily_tss 
    WHERE day = first_date
    
    UNION ALL
    
    -- Recursive
    SELECT
      d.day,
      (prev.ctl_float + (d.tss - prev.ctl_float) / 42.0) as ctl_float,
      (prev.atl_float + (d.tss - prev.atl_float) / 7.0) as atl_float
    FROM daily_tss d
    JOIN recursive_pmc prev ON d.day = (prev.day + INTERVAL '1 day')::date
  )
  SELECT
    day,
    ROUND(ctl_float)::integer as ctl,
    ROUND(atl_float)::integer as atl,
    ROUND(ctl_float - atl_float)::integer as tsb
  FROM recursive_pmc
  ORDER BY day;
END;
$$;
