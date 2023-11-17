-- Create networks first
CREATE TABLE networks (
    network_id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    ssid VARCHAR(255),
    password VARCHAR(255),
    auto_connect BOOLEAN
);

-- Create applications
CREATE TABLE applications (
    application_id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    apk TEXT
);

-- Create device_configuration
CREATE TABLE device_configuration (
    configuration_id SERIAL PRIMARY KEY,
    name VARCHAR(255)
);

-- Create devices
CREATE TABLE devices (
    device_id SERIAL PRIMARY KEY,
    configuration_id INTEGER REFERENCES device_configuration(configuration_id),
    model VARCHAR(255),
    manufacturer VARCHAR(255)
);

-- Create whiskers
CREATE TABLE whiskers (
    whisker_id SERIAL PRIMARY KEY,
    device_id INTEGER REFERENCES devices(device_id),
    sync_time TIMESTAMP,
    battery_level INTEGER,
    storage_usage INTEGER,
    location VARCHAR(255)
);

-- Create feeding_schedule
CREATE TABLE feeding_schedule (
    schedule_id SERIAL PRIMARY KEY,
    configuration_id INTEGER REFERENCES device_configuration(configuration_id)
);

-- Create feeding_records
CREATE TABLE feeding_records (
    feed_id SERIAL PRIMARY KEY,
    configuration_id INTEGER REFERENCES device_configuration(configuration_id),
    start_time TIMESTAMP,
    complete_time TIMESTAMP,
    status VARCHAR(100)
);

-- Create daily_feeding_time
CREATE TABLE daily_feeding_time (
    feed_time_id SERIAL PRIMARY KEY,
    schedule_id INTEGER REFERENCES feeding_schedule(schedule_id),
    time TIME
);

-- Create assigned_networks
CREATE TABLE assigned_networks (
    configuration_id INTEGER REFERENCES device_configuration(configuration_id),
    network_id INTEGER REFERENCES networks(network_id)
);

-- Create assigned_applications
CREATE TABLE assigned_applications (
    configuration_id INTEGER REFERENCES device_configuration(configuration_id),
    application_id INTEGER REFERENCES applications(application_id)
);

-- Create device_settings
CREATE TABLE device_settings (
    settings_id SERIAL PRIMARY KEY,
    configuration_id INTEGER REFERENCES device_configuration(configuration_id),
    settings_name VARCHAR(255),
    brightness INTEGER,
    screen_timeout INTEGER
);

-- Create commands
CREATE TABLE commands (
    device_id INTEGER,
    command_id SERIAL PRIMARY KEY,
    command VARCHAR(255),
    issue_time TIMESTAMP,
    sync_time TIMESTAMP,
    complete_time TIMESTAMP,
    status VARCHAR(100)
);

-- Get all whiskers
CREATE OR REPLACE FUNCTION public.get_all_whiskers_for_device(
    p_device_id integer)
    RETURNS TABLE(whisker_id integer, device_id integer, sync_time timestamp without time zone, battery_level integer, storage_usage integer, location character varying) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000
AS $BODY$
BEGIN
    RETURN QUERY SELECT w.whisker_id, w.device_id, w.sync_time, w.battery_level, w.storage_usage, w.location
    FROM whiskers AS w
    WHERE w.device_id = p_device_id;
END;
$BODY$;

ALTER FUNCTION public.get_all_whiskers_for_device(integer)
    OWNER TO postgres;

-- Create a new whisker
CREATE OR REPLACE PROCEDURE public.insert_new_whisker(
    IN device_id integer,
    IN sync_time timestamp without time zone,
    IN battery_level integer,
    IN storage_usage integer,
    IN location character varying)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
    INSERT INTO whiskers (device_id, sync_time, battery_level, storage_usage, location) 
    VALUES (device_id, sync_time, battery_level, storage_usage, location);
END;
$BODY$;
ALTER PROCEDURE public.insert_new_whisker(integer, timestamp without time zone, integer, integer, character varying)
    OWNER TO postgres;

-- Return all devices
CREATE OR REPLACE FUNCTION public.get_all_devices()
RETURNS TABLE(device_id INTEGER, configuration_id INTEGER, model VARCHAR, manufacturer VARCHAR) 
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
    RETURN QUERY SELECT d.device_id, d.configuration_id, d.model, d.manufacturer
    FROM devices AS d;
END;
$BODY$;

ALTER FUNCTION public.get_all_devices()
    OWNER TO postgres;

-- Insert a new device
CREATE OR REPLACE FUNCTION public.insert_new_device(
    IN model VARCHAR,
    IN manufacturer VARCHAR)
RETURNS INTEGER
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
    config_id INTEGER;
    new_device_id INTEGER;
BEGIN
    -- Check if default config exists
    SELECT configuration_id INTO config_id FROM device_configuration WHERE name = 'default';

    -- If not exists, create it
    IF NOT FOUND THEN
        INSERT INTO device_configuration (configuration_id, name) VALUES (0, 'default') RETURNING configuration_id INTO config_id;
    END IF;

    -- Insert the new device with the default config and return the new device_id
    INSERT INTO devices (configuration_id, model, manufacturer) VALUES (config_id, model, manufacturer) RETURNING device_id INTO new_device_id;

    RETURN new_device_id;
END;
$BODY$;

ALTER FUNCTION public.insert_new_device(VARCHAR, VARCHAR)
    OWNER TO postgres;

-- Delete a device
CREATE OR REPLACE PROCEDURE public.delete_device_by_id(
    IN id INTEGER)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
    -- Delete related whiskers
    DELETE FROM whiskers WHERE device_id = id;

    -- Delete related commands
    DELETE FROM commands WHERE device_id = id;

    -- Finally, delete the device
    DELETE FROM devices WHERE device_id = id;
END;
$BODY$;

ALTER PROCEDURE delete_device_by_id(INTEGER)
    OWNER TO postgres;
