
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