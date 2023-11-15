-- Create Networks first
CREATE TABLE Networks (
    NetworkID SERIAL PRIMARY KEY,
    Name VARCHAR(255),
    SSID VARCHAR(255),
    Password VARCHAR(255),
    AutoConnect BOOLEAN
);

-- Create Applications
CREATE TABLE Applications (
    ApplicationID SERIAL PRIMARY KEY,
    Name VARCHAR(255),
    APK TEXT
);

-- Create DeviceConfiguration
CREATE TABLE DeviceConfiguration (
    ConfigurationID SERIAL PRIMARY KEY,
    Name VARCHAR(255)
);

-- Create Devices
CREATE TABLE Devices (
    DeviceID SERIAL PRIMARY KEY,
    ConfigurationID INTEGER REFERENCES DeviceConfiguration(ConfigurationID),
    Model VARCHAR(255),
    Manufacturer VARCHAR(255)
);

-- Create Whiskers
CREATE TABLE Whiskers (
    WhiskerID SERIAL PRIMARY KEY,
    DeviceID INTEGER REFERENCES Devices(DeviceID),
    SyncTime TIMESTAMP,
    BatteryLevel INTEGER,
    StorageUsage INTEGER,
    Location VARCHAR(255)
);

-- Create FeedingSchedule
CREATE TABLE FeedingSchedule (
    ScheduleID SERIAL PRIMARY KEY,
    ConfigurationID INTEGER REFERENCES DeviceConfiguration(ConfigurationID)
);

-- Create FeedingRecords
CREATE TABLE FeedingRecords (
    FeedID SERIAL PRIMARY KEY,
    ConfigurationID INTEGER REFERENCES DeviceConfiguration(ConfigurationID),
    StartTime TIMESTAMP,
    CompleteTime TIMESTAMP,
    Status VARCHAR(100)
);

-- Create DailyFeedingTime
CREATE TABLE DailyFeedingTime (
    FeedTimeID SERIAL PRIMARY KEY,
    ScheduleID INTEGER REFERENCES FeedingSchedule(ScheduleID),
    Time TIME
);

-- Create AssignedNetworks
CREATE TABLE AssignedNetworks (
    ConfigurationID INTEGER REFERENCES DeviceConfiguration(ConfigurationID),
    NetworkID INTEGER REFERENCES Networks(NetworkID)
);

-- Create AssignedApplications
CREATE TABLE AssignedApplications (
    ConfigurationID INTEGER REFERENCES DeviceConfiguration(ConfigurationID),
    ApplicationID INTEGER REFERENCES Applications(ApplicationID)
);

-- Create DeviceSettings
CREATE TABLE DeviceSettings (
    SettingsID SERIAL PRIMARY KEY,
    ConfigurationID INTEGER REFERENCES DeviceConfiguration(ConfigurationID),
    SettingsName VARCHAR(255),
    Brightness INTEGER,
    ScreenTimeout INTEGER
);

-- Create Commands
CREATE TABLE Commands (
    DeviceID INTEGER,
    CommandID SERIAL PRIMARY KEY,
    Command VARCHAR(255),
    IssueTime TIMESTAMP,
    SyncTime TIMESTAMP,
    CompleteTime TIMESTAMP,
    Status VARCHAR(100)
);

-- Get all whiskers
CREATE OR REPLACE FUNCTION public.getallwhiskersfordevice(
    device_id integer)
    RETURNS TABLE(whiskerid integer, deviceid integer, synctime timestamp without time zone, batterylevel integer, storageusage integer, location character varying) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000
AS $BODY$
BEGIN
    RETURN QUERY SELECT w.WhiskerID, w.DeviceID, w.SyncTime, w.BatteryLevel, w.StorageUsage, w.Location
    FROM Whiskers AS w
    WHERE w.DeviceID = device_id;
END;
$BODY$;

ALTER FUNCTION public.getallwhiskersfordevice(integer)
    OWNER TO postgres;

-- Create a new whisker
CREATE OR REPLACE PROCEDURE public.insertnewwhisker(
    IN device_id integer,
    IN sync_time timestamp without time zone,
    IN battery_level integer,
    IN storage_usage integer,
    IN location character varying)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
    INSERT INTO Whiskers (DeviceID, SyncTime, BatteryLevel, StorageUsage, Location) 
    VALUES (device_id, sync_time, battery_level, storage_usage, location);
END;
$BODY$;
ALTER PROCEDURE public.insertnewwhisker(integer, timestamp without time zone, integer, integer, character varying)
    OWNER TO postgres;

-- Return all devices
CREATE OR REPLACE FUNCTION public.get_all_devices()
RETURNS TABLE(DeviceID INTEGER, ConfigurationID INTEGER, Model VARCHAR, Manufacturer VARCHAR) 
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
    RETURN QUERY SELECT d.DeviceID, d.ConfigurationID, d.Model, d.Manufacturer
    FROM Devices AS d;
END;
$BODY$;

ALTER FUNCTION public.get_all_devices()
    OWNER TO postgres;

-- Insert a new device
CREATE OR REPLACE FUNCTION public.InsertNewDevice(
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
    SELECT ConfigurationID INTO config_id FROM DeviceConfiguration WHERE Name = 'default';

    -- If not exists, create it
    IF NOT FOUND THEN
        INSERT INTO DeviceConfiguration (ConfigurationID, Name) VALUES (0, 'default') RETURNING ConfigurationID INTO config_id;
    END IF;

    -- Insert the new device with the default config and return the new DeviceID
    INSERT INTO Devices (ConfigurationID, Model, Manufacturer) VALUES (config_id, model, manufacturer) RETURNING DeviceID INTO new_device_id;

    RETURN new_device_id;
END;
$BODY$;

ALTER FUNCTION public.InsertNewDevice(VARCHAR, VARCHAR)
    OWNER TO postgres;

-- Delete a device

CREATE OR REPLACE PROCEDURE public.deleteDeviceByID(
    IN device_id INTEGER)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
    -- Delete related Whiskers
    DELETE FROM Whiskers WHERE DeviceID = device_id;

    -- Delete related Commands
    DELETE FROM Commands WHERE DeviceID = device_id;

    -- Finally, delete the device
    DELETE FROM Devices WHERE DeviceID = device_id;
END;
$BODY$;

ALTER PROCEDURE deleteDeviceByID(INTEGER)
    OWNER TO postgres;