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