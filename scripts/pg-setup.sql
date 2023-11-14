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

-- Function and Procedure definitions remain the same
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
