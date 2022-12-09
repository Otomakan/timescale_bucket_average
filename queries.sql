
SELECT  
time_bucket(INTERVAL '1 day', minute) as day,
device_id,
AVG(celcius) as celcius
FROM (
        SELECT  
				time_bucket_gapfill(INTERVAL '1 minute', time) as minute, 
				device_id, coalesce(AVG(celcius), 0) as celcius 
				FROM weather_ts
				WHERE device_id ='my_device_id' 
                AND time BETWEEN '2021-12-31' AND '2022-01-02'
				GROUP by 1, device_id
) ts
GROUP BY 1, device_id
order by day asc;
-- Returns accurate data but slowly 
-- Execution Time: 5.760 ms
--           day           |  device_id   |      celcius       
-- ------------------------+--------------+--------------------
--  2021-12-31 00:00:00+00 | my_device_id | 10.833333333333334
--  2022-01-01 00:00:00+00 | my_device_id | 10.819444444444445
--  2022-01-02 00:00:00+00 | my_device_id |                  0


  SELECT  
    time_bucket_gapfill(INTERVAL '1 day', time) as minute, 
    device_id, coalesce(AVG(celcius), 0) as celcius 
    FROM weather_ts
    WHERE device_id ='my_device_id' 
    AND time BETWEEN '2021-12-31' AND '2022-01-02'
    GROUP by 1, device_id

--  REturns wrong data pretty fast
--Execution Time: 1.179 ms
--        minute         |  device_id   | celcius 
-- ------------------------+--------------+---------
--  2021-12-31 00:00:00+00 | my_device_id |      20
--  2022-01-01 00:00:00+00 | my_device_id |      20
--  2022-01-02 00:00:00+00 | my_device_id |       0


SELECT * FROM weather_day_cagg
	WHERE device_id ='my_device_id' 
                AND time BETWEEN '2021-12-31' AND '2022-01-02'; 
 --Return wrong data extremely fast
 -- Execution Time: 0.248 ms
--           time          |  device_id   | celcius 
-- ------------------------+--------------+---------
--  2021-12-31 00:00:00+00 | my_device_id |      20
--  2022-01-01 00:00:00+00 | my_device_id |      20





EXPLAIN ANALYZE 
  SELECT  
    time_bucket_gapfill(INTERVAL '1 day', time) as minute, 
    device_id, coalesce(AVG(celcius), 0) as celcius 
    FROM weather_ts
    WHERE device_id ='my_device_id' 
    AND time BETWEEN '2021-12-31' AND '2022-01-02'
    GROUP by 1, device_id;

-- Planning Time: 0.798 ms
 --Execution Time: 1.179 ms


EXPLAIN ANALYZE SELECT  
time_bucket(INTERVAL '1 day', minute) as day,
device_id,
AVG(celcius) as celcius
FROM (
        SELECT  
				time_bucket_gapfill(INTERVAL '1 minute', time) as minute, 
				device_id, coalesce(AVG(celcius), 0) as celcius 
				FROM weather_ts
				WHERE device_id ='my_device_id' 
                AND time BETWEEN '2021-12-31' AND '2022-01-02'
				GROUP by 1, device_id
) ts
GROUP BY 1, device_id
order by day asc;

-- Execution Time: 5.760 ms


 EXPLAIN ANALYZE SELECT * FROM weather_day_cagg;

  -- Execution Time: 0.248 ms
