-- Update device_configuration update procedure
CREATE OR REPLACE PROCEDURE public.update_device_configuration(
    IN p_configuration_id INTEGER,
    IN p_new_name VARCHAR,
    IN p_brightness INTEGER,
    IN p_screen_timeout INTEGER,
    IN p_application_ids INTEGER[],
    IN p_network_ids INTEGER[],
    IN p_feeding_times TIME[])
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
    config_exists BOOLEAN;
    app_id INTEGER;
    net_id INTEGER;
    feed_time TIME;
BEGIN
    -- Check if configuration exists
    SELECT EXISTS(SELECT 1 FROM device_configuration WHERE configuration_id = p_configuration_id) INTO config_exists;

    IF NOT config_exists THEN
        -- Create new configuration if it does not exist
        INSERT INTO device_configuration (configuration_id, name, brightness, screen_timeout)
        VALUES (p_configuration_id, p_new_name, p_brightness, p_screen_timeout);
    ELSE
        -- Update existing configuration
        UPDATE device_configuration 
        SET name = p_new_name, 
            brightness = p_brightness, 
            screen_timeout = p_screen_timeout 
        WHERE configuration_id = p_configuration_id;
    END IF;

    -- Update AssignedApplications
    DELETE FROM assigned_applications WHERE configuration_id = p_configuration_id;
    FOREACH app_id IN ARRAY p_application_ids LOOP
        INSERT INTO assigned_applications (configuration_id, application_id) VALUES (p_configuration_id, app_id);
    END LOOP;

    -- Update AssignedNetworks
    DELETE FROM assigned_networks WHERE configuration_id = p_configuration_id;
    FOREACH net_id IN ARRAY p_network_ids LOOP
        INSERT INTO assigned_networks (configuration_id, network_id) VALUES (p_configuration_id, net_id);
    END LOOP;

    -- Update DailyFeedingTimes
    DELETE FROM daily_feeding_time WHERE configuration_id = p_configuration_id;
    FOREACH feed_time IN ARRAY p_feeding_times LOOP
        INSERT INTO daily_feeding_time (configuration_id, time) VALUES (p_configuration_id, feed_time);
    END LOOP;

END;
$BODY$;
ALTER PROCEDURE public.update_device_configuration(INTEGER, VARCHAR, INTEGER, INTEGER, INTEGER[], INTEGER[], TIME[])
    OWNER TO postgres;


-- Delete a configuration procedure adjusted
CREATE OR REPLACE PROCEDURE public.delete_configuration(
    IN config_id INTEGER)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
    -- Delete related AssignedApplications, AssignedNetworks, and DailyFeedingTimes
    DELETE FROM assigned_applications WHERE configuration_id = config_id;
    DELETE FROM assigned_networks WHERE configuration_id = config_id;
    DELETE FROM daily_feeding_time WHERE configuration_id = config_id;

    -- Finally, delete the configuration
    DELETE FROM device_configuration WHERE configuration_id = config_id;
END;
$BODY$;
ALTER PROCEDURE public.delete_configuration(INTEGER)
    OWNER TO postgres;

-- Get all configuration info
CREATE OR REPLACE FUNCTION get_full_configuration(_config_id INTEGER)
RETURNS TABLE (
    configuration_id INT,
    configuration_name VARCHAR(255),
    brightness INTEGER,
    screen_timeout INTEGER,
    networks JSONB,
    applications JSONB,
    feeding_times JSONB
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        dc.configuration_id,
        dc.name,
        dc.brightness,
        dc.screen_timeout,
        (
            SELECT JSONB_AGG(JSONB_BUILD_OBJECT(
                'network_id', n.network_id,
                'name', n.name,
                'ssid', n.ssid,
                'password', n.password,
                'auto_connect', n.auto_connect
            ))
            FROM assigned_networks an
            INNER JOIN networks n ON an.network_id = n.network_id
            WHERE an.configuration_id = dc.configuration_id
        ) AS networks,
        (
            SELECT JSONB_AGG(JSONB_BUILD_OBJECT(
                'application_id', a.application_id,
                'name', a.name,
                'apk', a.apk
            ))
            FROM assigned_applications aa
            INNER JOIN applications a ON aa.application_id = a.application_id
            WHERE aa.configuration_id = dc.configuration_id
        ) AS applications,
        (
            SELECT JSONB_AGG(dft.time)
            FROM daily_feeding_time dft
            WHERE dft.configuration_id = dc.configuration_id
        ) AS feeding_times
    FROM
        device_configuration dc
    WHERE
        dc.configuration_id = _config_id;
END;
$$ LANGUAGE plpgsql;
