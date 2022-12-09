

CREATE TABLE weather_ts (
device_id VARCHAR(40)  NOT NULL,
time TIMESTAMPTZ NOT NULL,
celcius FLOAT(2) 
);

ALTER TABLE weather_ts ADD CONSTRAINT  unique_device_timestamp  UNIQUE  (device_id, time);
SELECT create_hypertable('weather_ts', 'time');

CREATE INDEX ix_weather_did_time  ON weather_ts (device_id, time DESC);


CREATE MATERIALIZED VIEW weather_day_cagg
WITH (timescaledb.continuous) AS
SELECT
   time_bucket(INTERVAL '1 day', time) AS time,
   device_id,
   AVG(celcius) AS celcius
FROM weather_ts
GROUP BY device_id, 1;
