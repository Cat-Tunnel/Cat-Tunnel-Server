CREATE TABLE Commands (
    DeviceID INTEGER,
    CommandID SERIAL PRIMARY KEY,
    Command VARCHAR(255),
    IssueTime TIMESTAMP,
    SyncTime TIMESTAMP,
    CompleteTime TIMESTAMP,
    Status VARCHAR(100)
);
CREATE TABLE Whiskers (
    WhiskerID SERIAL PRIMARY KEY,
    DeviceID INTEGER REFERENCES Devices(DeviceID),
    SyncTime TIMESTAMP,
    BatteryLevel INTEGER,
    StorageUsage INTEGER,
    Location VARCHAR(255)
);
CREATE TABLE Devices (
    DeviceID SERIAL PRIMARY KEY,
    ConfigurationID INTEGER REFERENCES DeviceConfiguration(ConfigurationID),
    Model VARCHAR(255),
    Manufacturer VARCHAR(255)
);
CREATE TABLE DeviceConfiguration (
    ConfigurationID SERIAL PRIMARY KEY,
    Name VARCHAR(255)
);
CREATE TABLE FeedingSchedule (
    ScheduleID SERIAL PRIMARY KEY,
    ConfigurationID INTEGER REFERENCES DeviceConfiguration(ConfigurationID)
);
CREATE TABLE FeedingRecords (
    FeedID SERIAL PRIMARY KEY,
    ConfigurationID INTEGER REFERENCES DeviceConfiguration(ConfigurationID),
    StartTime TIMESTAMP,
    CompleteTime TIMESTAMP,
    Status VARCHAR(100)
);
CREATE TABLE DailyFeedingTime (
    FeedTimeID SERIAL PRIMARY KEY,
    ScheduleID INTEGER REFERENCES FeedingSchedule(ScheduleID),
    Time TIME
);
CREATE TABLE AssignedNetworks (
    ConfigurationID INTEGER REFERENCES DeviceConfiguration(ConfigurationID),
    NetworkID INTEGER REFERENCES Networks(NetworkID)
);
CREATE TABLE Networks (
    NetworkID SERIAL PRIMARY KEY,
    Name VARCHAR(255),
    SSID VARCHAR(255),
    Password VARCHAR(255),
    AutoConnect BOOLEAN
);
CREATE TABLE AssignedApplications (
    ConfigurationID INTEGER REFERENCES DeviceConfiguration(ConfigurationID),
    ApplicationID INTEGER REFERENCES Applications(ApplicationID)
);
CREATE TABLE Applications (
    ApplicationID SERIAL PRIMARY KEY,
    Name VARCHAR(255),
    APK TEXT
);
CREATE TABLE DeviceSettings (
    SettingsID SERIAL PRIMARY KEY,
    ConfigurationID INTEGER REFERENCES DeviceConfiguration(ConfigurationID),
    SettingsName VARCHAR(255),
    Brightness INTEGER,
    ScreenTimeout INTEGER
);
