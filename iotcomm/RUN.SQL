-- 1) Create database
CREATE DATABASE iotcomm_timescale;

-- 2) Connect to the iot database
\c iotcomm_timescale

-- 3) Create extension for timescaledb
CREATE EXTENSION IF NOT EXISTS timescaledb CASCADE;

-- 4) Create extension for postgis
CREATE EXTENSION IF NOT EXISTS postgis CASCADE;

-- 5) Create the table to store our readings
CREATE TABLE readings (
       "UID" VARCHAR NULL,
       app_id VARCHAR NULL,
       dev_id VARCHAR NULL,
       hardware_serial VARCHAR,
       port VARCHAR NULL,
       counter VARCHAR NULL,
       payload_raw VARCHAR NULL,
       payload_message VARCHAR NULL,
       metadata_time TIMESTAMP WITHOUT TIME ZONE,
       metadata_frequency DECIMAL NULL,
       metadata_modulation VARCHAR NULL,
       metadata_data_rate VARCHAR NULL,
       metadata_coding_rate VARCHAR NULL,
       metadata_gateways_0_gtw_id VARCHAR,
       metadata_gateways_0_timestamp DECIMAL NULL,
       metadata_gateways_0_time TIMESTAMP WITHOUT TIME ZONE,
       metadata_gateways_0_channel DECIMAL NULL,
       metadata_gateways_0_rssi DECIMAL NULL,
       metadata_gateways_0_snr DECIMAL NULL,
       metadata_gateways_0_rf_chain BOOLEAN NULL,
       metadata_gateways_0_latitude DECIMAL,
       metadata_gateways_0_longitude DECIMAL,
       metadata_gateways_0_altitude DECIMAL,
       metadata_gateways_0_location_source VARCHAR,
       metadata_latitude DECIMAL,
       metadata_longitude DECIMAL,
       metadata_altitude DECIMAL,
       metadata_location_source VARCHAR,
       metadata__SERVER VARCHAR
);

-- 6) Create a hypertable on table readings, with metadata.time as the partition column
SELECT CREATE_HYPERTABLE('readings', 'metadata_time');

-- 7) Create an index on metadata_time
CREATE INDEX ON readings(metadata_time DESC);

-- 8) Import our data
COPY readings FROM '/tmp/data.csv' DELIMITER ',' CSV HEADER;

-- 9) Reformat the payload to include payload_type, payload_value and payload_unit

-- *) Differentiate types of readings
SELECT payload_message,
CASE
    WHEN payload_message LIKE 'T%' THEN 'TEMPERATURE'
    WHEN payload_message LIKE 'H%' THEN 'HUMIDITY'
    ELSE ''
END AS payload_type,
CASE
    WHEN payload_message LIKE 'T%' THEN TRANSLATE(payload_message, 'T', '')
    WHEN payload_message LIKE 'H%' THEN TRANSLATE(payload_message, 'H', '')
    ELSE ''
END AS payload_value,
CASE
    WHEN payload_message LIKE 'T%' THEN 'C'
    WHEN payload_message LIKE 'H%' THEN '%'
    ELSE ''
END AS payload_unit
FROM readings;
