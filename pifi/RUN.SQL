-- 1) Create database
CREATE DATABASE pifi_timescale;

-- 2) Connect to the pifi
\c pifi_timescale

-- 3) Create extension for timescaledb
CREATE EXTENSION IF NOT EXISTS timescaledb CASCADE;

-- 4) Create extension for postgis
CREATE EXTENSION IF NOT EXISTS postgis CASCADE;

-- 5) Create the table to store our readings
CREATE TABLE readings (
       id decimal NOT NULL,
       uid VARCHAR NOT NULL,
       serial VARCHAR NOT NULL,
       uid_heartbeat VARCHAR NOT NULL,
       uid_session VARCHAR NOT NULL,
       datetime_logged TIMESTAMP WITHOUT TIME ZONE,
       src_mac VARCHAR NOT NULL,
       src_vendor VARCHAR,
       tgt_mac VARCHAR NOT NULL,
       rssi DECIMAL NOT NULL,
       probed_ssid VARCHAR,
       julianday_logged DECIMAL NOT NULL
);

-- 6) Create a hypertable on table readings, with datetime_logged as the partition column
SELECT CREATE_HYPERTABLE('readings', 'datetime_logged');

-- 7) Create an index on datetime_logged
CREATE INDEX ON readings(datetime_logged DESC);

-- 8) Import our data
COPY readings FROM '/tmp/data.csv' DELIMITER ',' CSV HEADER;
