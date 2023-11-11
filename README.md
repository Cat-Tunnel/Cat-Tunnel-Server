# Cat Tunnel

Welcome to CAT Tunnel, an evolving open-source project designed for efficient mobile device management (MDM). Our mission is to provide a lightweight, reliable, and user-friendly free and open-source MDM solution, specifically crafted for Android devices. CAT Tunnel is currently in the planning stage.

## What is Cat Tunnel?

Cat Tunnel is a containerized server solution that leverages the simplicity of JSON documents to manage and configure mobile devices remotely over a REST API.

### Configuration

The "C" in CAT represents Configuration. This feature allows for the desired state of all devices to be defined within JSON documents. These configurations can be applied during scheduled check-ins or on demand, which we like to call "feeding times". 

### Administration

"A" stands for Administration. This facet of Cat Tunnel enables live control of devices. From powering on/off to locking devices, remoting in, and even full remote control—administration is about real-time management and immediate action.

### Tracking

Lastly, "T" is for Tracking. This is where Cat Tunnel will perform monitoring and gathering performance metrics. Tracking is about having visibility and understanding the behavior of your fleet of devices.


## Technical Aspects
- **Containerized Server**: Ensures a scalable and isolated environment for running the CAT Tunnel server.
- **Document Uploads**: Accepts configuration documents in JSON, allowing complete control of the environment through configuration files alone.
- **Memory Options**: Run with volatile memory for transient data or integrate with your own PostgreSQL database for persistent storage.

## Project Status

As of now, Cat Tunnel is in the planning stage. This is a work in progress.