# Database Setup for Cat Tunnel Server

Cat Tunnel requires an outside PostgreSQL database for permenant configuration and history storage. This guide will walk you through the steps necessary to prepare your PostgreSQL server for integration with Cat Tunnel.

## Prerequisites

Before proceeding, ensure you have:

- PostgreSQL server installed and running.
- Credentials (username and password) to access your PostgreSQL server.
- Basic familiarity with PostgreSQL commands and operations.

## Step 1: Download the Database Script

First, download the provided database script from our repository. This script contains all the necessary commands to set up your database schema and initial data.

## Step 2: Connect to Your PostgreSQL Server

Access your PostgreSQL server using your preferred method. This could be through a command-line interface like `psql` or a graphical interface like pgAdmin.

- For `psql`, open your command prompt or terminal and connect using:
  ```
  psql -U [username] -d [database]
  ```
- For pgAdmin, open the application, connect to your server, and choose the appropriate database.

Replace `[username]` with your PostgreSQL username and `[database]` with the name of the database you wish to use.

## Step 3: Run the Database Script

Once connected to your database, you have two options to run the script:

### Option 1: Execute Script via Command Line

If you're using `psql`, you can execute the script directly with the following command:

```
\i /path/to/script.sql
```

Ensure to replace `/path/to/script.sql` with the actual file path of the downloaded script.

### Option 2: Import Script Using a Graphical Interface

For graphical tools like pgAdmin:

1. Navigate to the 'Query Tool'.
2. Open the script file using the 'Open File' option.
3. Execute the script by clicking the 'Execute/Run' button.