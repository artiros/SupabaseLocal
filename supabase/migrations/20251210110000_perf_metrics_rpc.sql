-- Function to calculate CTL, ATL, TSB for the authenticated user
CREATE OR REPLACE FUNCTION get_user_performance_metrics()
RETURNS TABLE (
  date date,
  ctl int,
  atl int,
  tsb int
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  curr_user_id uuid;
  first_date date;
BEGIN
  curr_user_id := auth.uid();
  
  -- If no user, return empty
  IF curr_user_id IS NULL THEN
    RETURN;
  END IF;

  SELECT MIN(start_date)::date INTO first_date FROM activities WHERE user_id = curr_user_id;

  -- Default to 90 days ago if no activities found, to show empty chart instead of nothing
  IF first_date IS NULL THEN
    first_date := CURRENT_DATE - INTERVAL '90 days';
  END IF;

  RETURN QUERY
  WITH daily_tss AS (
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
  calc AS (
    -- Anchor member
    (
      SELECT
        dt.day,
        dt.tss::numeric as tss,
        dt.tss::numeric as ctl,
        dt.tss::numeric as atl
      FROM daily_tss dt
      WHERE dt.day = first_date
    )
    UNION ALL
    -- Recursive member
    (
      SELECT
        dt.day,
        dt.tss::numeric,
        (c.ctl + (dt.tss - c.ctl) / 42.0) as ctl,
        (c.atl + (dt.tss - c.atl) / 7.0) as atl
      FROM daily_tss dt
      JOIN calc c ON dt.day = c.day + INTERVAL '1 day'
    )
  )
  SELECT
    c.day as date,
    ROUND(c.ctl)::int as ctl,
    ROUND(c.atl)::int as atl,
    ROUND(c.ctl - c.atl)::int as tsb
  FROM calc c
  ORDER BY c.day;

END;
$$;
