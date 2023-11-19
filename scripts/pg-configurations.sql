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
