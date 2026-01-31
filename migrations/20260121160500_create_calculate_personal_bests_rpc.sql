create or replace function calculate_personal_bests(target_user_id uuid)
returns void
language plpgsql
security definer
as $$
declare
  dist record;
  best_time record;
  standard_distances numeric[] := array[
    -- Swim
    400, 750, 1500, 1900, 3800,
    -- Run
    5000, 10000, 21097, 42195,
    -- Bike (Standard TT distances)
    20000, 40000, 90000, 180000
  ];
  d numeric;
  tolerance numeric := 0.05; -- 5% tolerance for distance matching
begin
  -- Iterate through standard distances
  foreach d in array standard_distances
  loop
    -- Find best Run
    select * into best_time
    from activities
    where user_id = target_user_id
      and type = 'Run'
      and distance >= d 
      and distance <= (d * (1 + tolerance))
    order by moving_time asc
    limit 1;

    if found then
      insert into personal_bests (user_id, activity_type, distance_meters, time_seconds, achieved_at, source)
      values (target_user_id, 'Run', d, best_time.moving_time, best_time.start_date, 'auto')
      on conflict (user_id, activity_type, distance_meters) 
      do update set 
        time_seconds = excluded.time_seconds,
        achieved_at = excluded.achieved_at,
        source = 'auto'
      where personal_bests.source = 'auto' and excluded.time_seconds < personal_bests.time_seconds;
    end if;

    -- Find best Ride (Bike)
    select * into best_time
    from activities
    where user_id = target_user_id
      and type = 'Ride'
      and distance >= d 
      and distance <= (d * (1 + tolerance))
    order by moving_time asc
    limit 1;

    if found then
      insert into personal_bests (user_id, activity_type, distance_meters, time_seconds, achieved_at, source)
      values (target_user_id, 'Ride', d, best_time.moving_time, best_time.start_date, 'auto')
      on conflict (user_id, activity_type, distance_meters) 
      do update set 
        time_seconds = excluded.time_seconds,
        achieved_at = excluded.achieved_at,
        source = 'auto'
      where personal_bests.source = 'auto' and excluded.time_seconds < personal_bests.time_seconds;
    end if;
    
    -- Find best Swim
    select * into best_time
    from activities
    where user_id = target_user_id
      and type = 'Swim'
      and distance >= d 
      and distance <= (d * (1 + tolerance))
    order by moving_time asc
    limit 1;

    if found then
      insert into personal_bests (user_id, activity_type, distance_meters, time_seconds, achieved_at, source)
      values (target_user_id, 'Swim', d, best_time.moving_time, best_time.start_date, 'auto')
      on conflict (user_id, activity_type, distance_meters) 
      do update set 
        time_seconds = excluded.time_seconds,
        achieved_at = excluded.achieved_at,
        source = 'auto'
      where personal_bests.source = 'auto' and excluded.time_seconds < personal_bests.time_seconds;
    end if;

  end loop;
end;
$$;
