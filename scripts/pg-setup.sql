-- Create networks
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
    name VARCHAR(255),
    brightness INTEGER,
    screen_timeout INTEGER
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

-- Create feeding_records
CREATE TABLE feeding_records (
    feed_id SERIAL PRIMARY KEY,
    device_id INTEGER REFERENCES devices(device_id),
    start_time TIMESTAMP,
    complete_time TIMESTAMP,
    status VARCHAR(100)
);

-- Update daily_feeding_time to directly reference device_configuration
CREATE TABLE daily_feeding_time (
    feed_time_id SERIAL PRIMARY KEY,
    configuration_id INTEGER REFERENCES device_configuration(configuration_id),
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

-- Create commands
CREATE TABLE commands (
    device_id INTEGER REFERENCES devices(device_id),
    command_id SERIAL PRIMARY KEY,
    command VARCHAR(255),
    issue_time TIMESTAMP,
    sync_time TIMESTAMP,
    complete_time TIMESTAMP,
    status VARCHAR(100)
);


