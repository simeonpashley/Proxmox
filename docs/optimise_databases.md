archived from  [smarthomescene.com](https://smarthomescene.com/guides/optimize-your-home-assistant-database/)

---

# Optimize Your Home Assistant Database

Table of Contents

- [Why change and optimize the default database?](#Why_change_and_optimize_the_default_database "Why change and optimize the default database?")
- [Recorder vs History vs Logbook](#Recorder_vs_History_vs_Logbook "Recorder vs History vs Logbook")
- [MariaDB vs InfluxDB](#MariaDB_vs_InfluxDB "MariaDB vs InfluxDB")
- [Installation and Setup](#Installation_and_Setup "Installation and Setup")
  - [MariaDB](#MariaDB "MariaDB")
  - [InfluxDB](#InfluxDB "InfluxDB")
- [Using both MariaDB and InfluxDB](#Using_both_MariaDB_and_InfluxDB "Using both MariaDB and InfluxDB")
- [Optimizing your databases](#Optimizing_your_databases "Optimizing your databases")
  - [MariaDB](#MariaDB-2 "MariaDB")
  - [InfluxDB](#InfluxDB-2 "InfluxDB")
- [Optimizing your entities](#Optimizing_your_entities "Optimizing your entities")
- [Purging Database](#Purging_Database "Purging Database")
- [Tracking Database Size](#Tracking_Database_Size "Tracking Database Size")
- [Summary](#Summary "Summary")

Home Assistant uses a database to store events and parameters for history and tracking of your entities. The default database used in a fresh install is [**SQLite**](https://www.sqlite.org/index.html), which creates a file in your config directory (e.g config/home-assistant_v2.db). To change the default database library, we need to use the recorder component in Home Assistant.

In this tutorial, we are going to talk about how you can set up **MariaDB** as a main SQL recorder database, setup up **InfluxDB**, a time-series database for longer data retention and how to use them both simultaneously. Finally, we are going to show you how to **fine-tune** your entities for history keeping.

## Why change and optimize the default database?

You might wonder, why change the default database? Why include or exclude specific entities in the database when I can record them all? The answer depends on you Home Assistant installation method, the amount of devices you integrated in HA and the amount of data you want to keep for a specific amount of time.

Although the default SQLite is fine for the average user, and can be fine tuned to include or exclude entities for record keeping, we suggest switching to a better, more optimized database library, such as **MariaDB**. They are both [Relational DBMS](https://db-engines.com/en/article/Relational+DBMS?ref=RDBMS), and serve the same purpose, but MariaDB is **superior** in **handling large datasets**, **easier extraction of data/integrations and is faster when displaying history** in Home Assistant.

By default, Home Assistant keeps data for around 10 days for usage in the history and logbook integrations using SQLite. If you have a lot of devices which in turn create a lot of entities, HA writes a lot of events and parameters in the .db file. This is very heavy on your storage medium (especially SD Cards), as it produces many I/O cycles.

For example, If you run your HA on a Raspberry Pi using an SD card, the card failing is not a question of **WILL IT** fail but a question of **WHEN WILL IT** fail? The recorder is the main culprit for crashing a Home Assistant instance running from an SD Card.

First and foremost, to protect your HA server and save yourself some headaches from having to rebuild, we **HIGHLY** suggest using a **backup** method, such as the [**Home Assistant Google Drive Backup Integration.**](https://github.com/sabeechen/hassio-google-drive-backup)

Finally, to solidify your setup, you need to properly setup and optimize your database. Of course you want to record who opened the main door and at what time, but does keeping a history of your Raspberry’s RAM usage is important? Probably not.

## Recorder vs History vs Logbook

Before we go on any further with this tutorial, we feel like it’s important to clarify the difference between Home Assistant’s **recorder, history and logbook** integration.

- The **Recorder** integration is responsible for storing events, states and data in the main SQL database. It simply handles the backend logic of the database
- The **History** integration is responsible for displaying data from the recorder in the UI using Google Graphs
- The **Logbook** integration is responsible for showing changes and events in a list sorted reverse chronologically


![](https://smarthomescene.com/wp-content/uploads/2022/04/ha-database-history.jpg)


![](https://smarthomescene.com/wp-content/uploads/2022/04/ha-database-logbook.jpg)

The important things to takeaway from this is:

- If the recorder is disabled for a specific entity, the history and logbook also become unavailable.
- If the recorder is enabled for a specific entity, you can selectively disable the history or logbook from its displaying data in the UI

Each of these components use the same filter logic to include/exclude entities in the integration itself. Filter are explained further down the tutorial.

**Note:** InfluxDB is not meant to replace the recorder component. It is meant run along side it for long term data keeping.

## MariaDB vs InfluxDB

Both Maria and Influx are enhanced database tools, but they are in different in many ways. InfluxDB is generally explained as a “_An open-source distributed time series database with no external dependencies”_ while MariaDB as “_An enhanced, drop-in replacement for MySQL”._

**MariaDB**

- **Primary database model:** Relational DBMS
- **Secondary database model:** Document Store, Graph DMBS, Spatial DBMS
- **Released:** 2009
- **Usage in HA:** Natively, replace default SQLite database

**InfluxDB**

- **Primary database model:** Time-series DMBS
- **Secondary database model:** Spatial DMBS
- **Released:** 2013
- **Usage in HA:** Long-term data retention, create advanced graphs using Grafana, Kibana

In short, MariaDB will replace the default SQLite Home Assistant database and give you a speed boost. InfluxDB will store long-term data more efficiently, from which you can build advanced graph using Grafana.

## Installation and Setup

### MariaDB

To install MariaDB, navigate to the Supervisor add-on store and search for MariaDB. Click install and enable the **Start on Boot** and **Watchdog** toggles.


![](https://smarthomescene.com/wp-content/uploads/2022/04/ha-database-mariadb.jpg)

Open the **Configuration tab** to setup your database name and login credentials:

    databases:
      - homeassistant #Change if you want
    logins:
      - username: !secret mariadb_user
        password: !secret mariadb_pass
    rights:
      - username: !secret mariadb_user
        database: homeassistant

Next, open the ***secrets.yaml*** file and add your login credentials along with a **mariadb_url**, just like the example. We will use this line to enable the database for the Recorder integration. Change the **‘homeassistant’** database name to whatever you named yours in this URL.

    #Secrets.yaml
    mariadb_user: smarthomescene
    mariadb_pass: 12345678
    mariadb_url: mysql://smarthomescene:[email protected]/homeassistant?charset=utf8mb4

To enable MariaDB, open your _**configuration.yaml**_ file and add the following line. Feel free to use **!include** if you want.

    recorder:
      db_url: !secret mariadb_url
      purge_keep_days: 30
      commit_interval: 20
      .....

### InfluxDB

To install InfluxDB, navigate to the Supervisor add-on store and search for InfluxDB. Click install and enable the **Start on Boot** and **Watchdog** toggles. You can also tick **Show in sidebar**, as we will use the InfluxDB interface to setup our database.

![](https://smarthomescene.com/wp-content/uploads/2022/04/ha-database-influxdb.jpg)

After you have installed InfluxDB, open it’s web interface. On the left side of the UI, open the **Influx Admin** panel and click **‘+ Create Database’** at the top. Name your database and click the checkmark. Under the retention policy setting, you can edit the **Duration** for which InfluxDB will hold data. As this is a time-series database which we will setup for longer data retention for specific entities, we suggest using a longer time range or set it to indefinitely.

![](https://smarthomescene.com/wp-content/uploads/2022/04/ha-database-influxdb-admin-database.jpg)

Next, select the Users tab on the left and click **‘+ Create User’.** Name your user and set a password. Once created, click **Edit** and make sure you give **All permissions** to the user.

![](https://smarthomescene.com/wp-content/uploads/2022/04/ha-database-influxdb-admin-user.jpg)

To enable the InfluxDB integration, open **configuration.yaml** and add the following

    influxdb:
      host: 192.168.0.xxx
      port: 8086
      database: homeassistant
      username: homeassistant
      password: !secret influxdb_pass
      max_retries: 3
      default_measurement: state

Set your internal IP address as a host for InfluxDB and port 8086. Input the database you created along with the user credentials. Again, you can use your _**secrets.yaml**_ file to store database, username and password.

## Using both MariaDB and InfluxDB

After both MariaDB and InfluxDB are installed and setup, Home Assistant will use both of them to store data. However, because we have not told HA which entities to include in which database, it will populate both databases and you will have duplicate entries. This is redundant and will increase your backups size unnecessary.

To decide which entities you want to keep track of for a longer period of time, you need to ask yourself the following question: **Will this data will be useful to me 6 months or a year from now?**

If the answer is **Yes**, that entity belongs to InfluxDB. If the answer is **No**, than the entity belongs to MariaDB.

**Note:** It’s possible some entities belong in both databases. For example, if you have a room temperature sensor and want to display it’s data ***natively*** in Lovelace, you can add it to MariaDB and retain it’s data for 15 days for example. If you want to extract an average room temperature during the winter season, you can add the sensor in InfluxDB and retain the data indefinitely or until purged.

## Optimizing your databases

Optimizing your database and entities can be a time consuming task, especially if you have a lot of devices which expose a lot of entities in Home Assistant. I think you will find going trough this process worthwhile, as it can and will significantly improve your HA experience.

Both MariaDB and InfluxDB offer a variety of configuration variables, used to tweak the settings and performance of the database. You can go through all of them here: [**MariaDB**](https://www.home-assistant.io/integrations/recorder/#configuration-variables) | [**InfluxDB**](https://www.home-assistant.io/integrations/influxdb/#configuration-variables)

For the purpose of this tutorial, we will explain a couple which we feel are important.

### MariaDB

As you will be using MariaDB for short time span data retention and, in turn, display this data into Lovelace, we suggest setting the time interval to 7-30 days. If you want to track a longer period, you can, but this entity would probably belong to InfluxDB.

- \***\*auto_purge:\*\*** Automatically purge the database every night at 04:12 local time.
- **purge_keep_days:** Specify the number of history days to keep in recorder database after a purge.
- \***\*commit_interval:\*\*** How often (in seconds) the events and state changes are committed to the database. The default of **1** allows events to be committed almost right away without trashing the disk when an event storm happens. Increasing this will reduce disk I/O and may prolong disk (SD card) lifetime with the trade-off being that the logbook and history will lag. If this is set to **0 (zero)**, commit are made as soon as possible after an event is processed.

### InfluxDB

Because the data retention policy is already set for InfluxDB in the UI, we do not need to add a configuration variable for the database. The important thing to note when configuring InfluxDB, is that you can use two versions of the API. Each of them requires different configuration and setup. In our example, we used version InfluxDB 1.0. You can setup InfluxDB 2.0 by following their official guide [**here**](https://docs.influxdata.com/influxdb/v2.0/).

**Note:** Configuration for version 2.xx is significantly different and require different steps for setup. Furthermore, it uses Flux querry language, instead of the InfluxQL for the 1.xx version. If you’ve used the first, we suggest sticking to it as they are very different.

## Optimizing your entities

Before you start including or excluding entities from the recorder, you might want an editable list to copy-paste in an Excel table for example. To get this list, open Developer Tools > Templates and paste the following code:

    {% for state in states %}
      - {{ state.entity_id -}}
    {% endfor %}

This will list all your entities, without their attributes or actual states. You can transfer this to your favorite cell editor and work your way through them more easily.

Both databases use the same configuration filters to include or exclude entities from being tracked. You can add this under the _**recorder**_ integration for MariaDB or under _**influxdb**_ for InfluxDB. To handle entities recording, we have a couple of options.

- **No Includes or Exclude:** Record all entities
- **Includes, No Excludes:** Record only included entities, exclude everything else
- **Excludes, No Includes:** Record everything, except for excluded entities
- **Includes and Excludes:** Combination of both for specific use cases

For each of these filters, we can use _**domains**_, _**entity_globs**_, or _**entities**_ as a specific category for filtering:

- **domains:** include/exclude entire domains (eg. _**light**_)
- **entity_globs:** include/exclude entities matching a listed pattern (eg. _**sensor.weather\_\***_)
- **entities:** include/exclude specific entities (eg. _**sensor.disk_free**_)

**Example 1:** Includes only

    recorder:
      db_url: !secret mariadb_url
      purge_keep_days: 30
      commit_interval: 20
      include: #Include entities
        domains:
          - light
        entity_globs:
          - sensor.weather_*
        entities:
          - sensor.disk_free
          - sensor.disk_use
          - sensor.disk_use_percent

**Example 2:** Excludes only

    recorder:
      db_url: !secret mariadb_url
      purge_keep_days: 30
      commit_interval: 20
      exclude: #Exclude entities
        domains:
          - automation
          - script
        entity_globs:
          - binary_sensor.*_occupancy
        entities:
          - switch.living_room_light
          - light.bathroom_light
          - sensor.processor_temperature

**Example 3:** Includes and Excludes

    recorder:
      db_url: !secret mariadb_url
      purge_keep_days: 30
      commit_interval: 20
      include: #Include domain
        domains:
          - light
      exclude: #Exclude entities
        entities:
          - light.living_room_light

With this configuration in example 3, we have setup the integration to record all entities from the light domain, _**except**_ the living room light. If you apply this logic when filtering entities, you code should not be more than a few lines.

**Example 4:** InfluxDB Example

    influxdb:
      host: 192.168.0.xxx
      port: 8086
      database: homeassistant
      username: homeassistant
      password: !secret influxdb_pass
      max_retries: 3
      default_measurement: state
      include: #Include Domain
        domains:
          - light
      exclude: #Exclude Entities
        entities:
          - light.living_room_light

**Example 5:** History Example

    history:
      exclude:
        domains:
          - automation
          - updater
        entities:
          - sensor.last_boot
          - sensor.date
        entity_globs:
          - binary_sensor.*_occupancy

**Example 6:** Logbook Example

    logbook:
      include:
        domains:
          - alarm_control_panel
          - light
        entity_globs:
          - binary_sensor.*_occupancy
      exclude:
        entities:
          - light.kitchen_light

## Purging Database

If we want to manually purge the database of MariaDB, we fire a call-service in the Developer Tools Menu:

    ### Purge a single entity ###
    service: recorder.purge_entities
    target:
      entity_id: alarm_control_panel.apartment

    ### Purge a single entity ###
    service: recorder.purge_entities
    data:
      domains: light


    ### Purge the ENTIRE database ###
    service: recorder.purge
    data:
      repack: true

The last call-service will purge the entire database and issue a ***repack*** command. Please note that this is a heavy command, which will rebuild the entire database, optimize or recreate the events and states tables. Use this only if you have slowdown issues.

If you want to purge the InfluxDB database, you can open the UI, navigate to the InfluxDB Explore Panel execute a simple query:

    USE "homeassistant"; DELETE WHERE time < '2022-04-04'

If you want to purge a single entity, you can run the following query for example:

    USE "homeassistant"; DELETE WHERE "entity_id" = 'sensor.bathroom_temperature' AND time < '2022-04-04'

## Tracking Database Size

To monitor the file size of our databases, we can create two template sensors which query the database and return the value in a sensor entity.

    sensor:
      #MariaDB Database Sensor
      - platform: sql
        db_url: !secret mariadb_url
        scan_interval: 3600
        queries:
          - name: MariaDB Database Size
            query: 'SELECT table_schema "homeassistant", Round(Sum(data_length + index_length) / POWER(1024,2), 1) "value" FROM information_schema.tables WHERE table_schema="homeassistant" GROUP BY table_schema;'
            column: "value"
            unit_of_measurement: MB
      #InfluxDB Database Sensor
      - platform: influxdb
        host: 192.168.0.xxx
        port: 8086
        username: homeassistant
        password: !secret influxdb_pass
        scan_interval: 3600
        queries:
          - name: InfluxDB Database Size
            unit_of_measurement: MB
            value_template: "{{ (value | float(0) / 1024 /1024) | round(1) }}"
            group_function: sum
            measurement: '"monitor"."shard"'
            database: _internal
            where: '"database"=''homeassistant'' AND time > now() - 5m'
            field: diskBytes

If you’ve labeled your database differently make sure to replace the **“homeassistant”** part under the query attribute in the template sensor configuration.

## Summary

The process of optimizing your Home Assistant database can be a time consuming process, especially if you have a lot of entities to go through. We suggest using logic and common sense, to filter your entities properly. Instead of listing **specific entities** for recording, try to include by using the **domain** variable and than only exclude what you do not need. What you record is ultimately up to you and your needs.

For tutorial purposes, here is a list of entities that you **probably do not want or need** recorded in any database.

- System Monitor: RAM, CPU, NETWORK and DISK usage
- Mobile Device: Battery Level, Public IP address, Internal Storage
- Batteries Percentages for different sensors
- Battery Low Binary Sensors
- Zones
- Most Scripts
- Some Automations
