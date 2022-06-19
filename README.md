## Home Assistant on Proxmox - common helper apps

2022-07-14 The info below was forked from another upstream repo that was taken offline, and ultimately had bad links inside so I repaired them here.

Beyond those URL fixes, it largely remains untouched.

A collection of commonly used services that can be simply setup using Proxmox and then woven into Home Assistant.

### How to Reset forgotten LXC Container root password on Proxmox VE(PVE)

1. Login to PVE web gui first

2. From the Datacenter view at our left hand side, find the LXC container which we want to reset password for and remember the ID of the container e.g. If we see a container named 200 (testContainer), 200 is its ID, testContainer is its name

3. Now start the container

4. Connect to PVE host (as root user) via SSH or open a Shell/Console from the top right corner >_ Console button of PVE web gui

5. Use the following command to attach our session to the LXC container

**Replace <ID> with the correct LXC container's ID**

`lxc-attach -n <ID>`


6. Change the password for the container

`passwd`
 
Type the new password, Press Enter key, then type the password and Press Enter key again to set the new password for the container

7. Once done, we can login to the container with the new password



---

### Select a Proxmox Helper Below

Inside each drop-down are the instructions for setting up the service, typically via Proxmox web shell.

<details>
<summary>Home Assistant OS VM</summary>
 
<h1 align="center" id="heading"> Proxmox VM with Home Assistant OS </h1>

To create a new Proxmox VM with the latest version of Home Assistant OS, run the following from Proxmox web shell

```
bash -c "$(wget -qLO - https://raw.githubusercontent.com/simeonpashley/Proxmox/main/haos_vm.sh)"
```

### <h3 align="center" id="heading">:zap: Default Settings: 4GB RAM - 32GB Storage - 2vCPU :zap:</h3>

After the script completes, If you're dissatisfied with the default settings, click on the VM, then on the **_Hardware_** tab and change the **_Memory_** and **_Processors_** settings to what you desire. Once all changes have been made, **_Start_** the VM.

</details>

<details>
<summary>PVE6 Home Assistant Container LXC</summary>

<h1 align="center" id="heading"> Proxmox 6 Home Assistant LXC Container </h1>

To create a new Proxmox 6 Home Assistant Container, run the following from Proxmox web shell.

```
bash -c "$(wget -qLO - https://raw.githubusercontent.com/simeonpashley/Proxmox/main/pve6_ha_container.sh)"
```

<h3 align="center" id="heading">:zap: Default Settings:  4GB RAM - 16GB Storage - 2vCPU :zap:</h3>
 
After the script completes, If you're dissatisfied with the default settings, click on the LXC, then on the **_Resources_** tab and change the **_Memory_** and **_Cores_** settings to what you desire. Changes are immediate.

For Home Assistant interface http:// (LXC IP) :8123

For Portainer interface http:// (LXC IP) :9000

Path to HA configuration.yaml

```
/var/lib/docker/volumes/hass_config/_data
```

</details>

<details>
<summary>PVE7 Home Assistant Container LXC</summary>

<h1 align="center" id="heading"> Proxmox 7 Home Assistant LXC Container </h1>

To create a new Proxmox 7 Home Assistant Container, run the following from Proxmox web shell.

```
bash -c "$(wget -qLO - https://raw.githubusercontent.com/simeonpashley/Proxmox/main/pve7_ha_container.sh)"
```

<h3 align="center" id="heading">:zap: Default Settings:  4GB RAM - 16GB Storage - 2vCPU :zap:</h3>
 
After the script completes, If you're dissatisfied with the default settings, click on the LXC, then on the **_Resources_** tab and change the **_Memory_** and **_Cores_** settings to what you desire. Changes are immediate.

For Home Assistant interface http:// (LXC IP) :8123

For Portainer interface http:// (LXC IP) :9000

Path to HA configuration.yaml

```
/var/lib/docker/volumes/hass_config/_data
```

</details>

<details>
<summary>ESPHome LXC</summary>

<h1 align="center" id="heading"> Proxmox ESPHome LXC Container </h1>

To create a new Proxmox ESPHome LXC Container, run the following from Proxmox web shell.

```
bash -c "$(wget -qLO - https://raw.githubusercontent.com/simeonpashley/Proxmox/main/esphome_container.sh)"
```

<h3 align="center" id="heading">:zap: Default Settings:  1GB RAM - 4GB Storage - 2vCPU :zap:</h3>
 
</details>

<details>
<summary>MQTT LXC</summary>

<h1 align="center" id="heading"> Proxmox MQTT LXC Container </h1>

To create a new Proxmox MQTT LXC Container, run the following in the Proxmox web shell.

```
bash -c "$(wget -qLO - https://raw.githubusercontent.com/simeonpashley/Proxmox/main/mqtt_container.sh)"
```

<h3 align="center" id="heading">:zap: Default Settings:  512MiB RAM - 2GB Storage - 1vCPU :zap:</h3>
 
Mosquitto comes with a password file generating utility called mosquitto_passwd.
```
sudo mosquitto_passwd -c /etc/mosquitto/passwd <usr>
```
Password: < password >

Create a configuration file for Mosquitto pointing to the password file we have just created.

```
sudo nano /etc/mosquitto/conf.d/default.conf
```

This will open an empty file. Paste the following into it.

```
allow_anonymous false
persistence true
password_file /etc/mosquitto/passwd
listener 1883
```

Save and exit the text editor with "Ctrl+O", "Enter" and "Ctrl+X".

Now restart Mosquitto server.

```
sudo systemctl restart mosquitto
```

</details>

<details>
<summary>Node-Red LXC</summary>

<h1 align="center" id="heading"> Proxmox Node-Red LXC Container </h1>

To create a new Proxmox Node-RED LXC Container, run the following in the Proxmox web shell.

```
bash -c "$(wget -qLO - https://raw.githubusercontent.com/simeonpashley/Proxmox/main/node-red_container.sh)"
```

<h3 align="center" id="heading">:zap: Default Settings:  1GB RAM - 4GB Storage - 1vCPU :zap:</h3>
 
**BONUS**

Add in some spicy node-red nodes. Connect to the console for the Node-Red host you just created.

```bash
cd ~/.node-red/

npm install --save node-red-contrib-home-assistant-websocket node-red-contrib-bigtimer node-red-contrib-boolean-logic node-red-contrib-config node-red-contrib-diode node-red-contrib-dsm node-red-contrib-influxdb node-red-contrib-isonline node-red-contrib-moment node-red-contrib-npm node-red-contrib-owntracks node-red-contrib-sun-position node-red-contrib-telegrambot node-red-contrib-timeout node-red-dashboard node-red-node-geofence node-red-node-google node-red-node-openweathermap node-red-node-ping node-red-node-random node-red-node-smooth
```
 
Other nodes to consider, which I didn't want.
 
`node-red-contrib-aedes node-red-contrib-alexa-local node-red-contrib-alexa-notifyme node-red-contrib-amazon-echo node-red-contrib-blynk-ws node-red-contrib-esplogin node-red-contrib-file-function node-red-contrib-fs-ops node-red-contrib-ftp node-red-contrib-grove node-red-contrib-heater-controller node-red-contrib-ibm-watson-iot node-red-contrib-particle node-red-contrib-ramp-thermostat node-red-contrib-tuya-local node-red-contrib-ui-led node-red-contrib-web-worldmap node-red-contrib-yr node-red-node-arduino node-red-node-emoncms node-red-contrib-advanced-ping`

</details>

 <details>
<summary>Mariadb 10.5 LXC</summary>

<h1 align="center" id="heading"> Proxmox Mariadb 10.5 LXC Container </h1>

To create a new Proxmox Mariadb LXC Container, run the following in the Proxmox web shell.

```
bash -c "$(wget -qLO - https://raw.githubusercontent.com/simeonpashley/Proxmox/main/mariadb_container.sh)"
```

<h3 align="center" id="heading">:zap: Default Settings:  1GB RAM - 4GB Storage - 1vCPU :zap:</h3>
 
To enable MariaDB to listen to remote connections, you need to edit your defaults file. To do this, open the console in your MariaDB lxc:
```
nano /etc/mysql/my.cnf
```
Un-comment `port =3306`
Save and exit the editor with "Ctrl+O", "Enter" and "Ctrl+X".

```
nano /etc/mysql/mariadb.conf.d/50-server.cnf
```

Comment `bind-address = 127.0.0.1`
Save and exit the editor with "Ctrl+O", "Enter" and "Ctrl+X".

For new MariaDB installations, the next step is to run the included security script. This script changes some of the less secure default options. We will use it to block remote root logins and to remove unused database users.

Run the security script:

```
sudo mysql_secure_installation
```

Enter current password for root (enter for none): enter

Switch to unix_socket authentication [Y/n] y

Change the root password? [Y/n] n

Remove anonymous users? [Y/n] y

Disallow root login remotely? [Y/n] y

Remove test database and access to it? [Y/n] y

Reload privilege tables now? [Y/n] y

We will create a new account called admin with the same capabilities as the root account, but configured for password authentication.

```
sudo mysql
```

Prompt will change to `MariaDB [(none)]>`

Create a new local admin (Change the username and password to match your preferences)

```
CREATE USER 'admin'@'localhost' IDENTIFIED BY 'password';
```

Give local admin root privileges (Change the username and password to match above)

```
GRANT ALL ON *.* TO 'admin'@'localhost' IDENTIFIED BY 'password' WITH GRANT OPTION;
```

Now, we'll give the user admin root privileges and password-based access that can connect from anywhere on my local area network (LAN), which has addresses in the subnet 192.168.100.0/24. This is an improvement because opening a MariaDB server up to the Internet and granting access to all hosts is bad practice.. Change the username, password and subnet to match your preferences:

```
GRANT ALL ON *.* TO 'admin'@'192.168.100.%' IDENTIFIED BY 'password' WITH GRANT OPTION;
```

Flush the privileges to ensure that they are saved and available in the current session:

```
FLUSH PRIVILEGES;
```

Following this, exit the MariaDB shell:

```
exit
```

Log in as the new database user you just created:

```
mysql -u admin -p
```

Create a new database:

```
CREATE DATABASE homeassistant;
```

Following this, exit the MariaDB shell:

```
exit
```

:warning: Reboot the lxc

Checking status.

```
sudo systemctl status mariadb
```

Change the recorder: `db_url:` in your HA configuration.yaml

Example: `mysql://admin:password@192.168.100.26:3306/homeassistant?charset=utf8mb4`
 
### Further reading
Take a look at  `HA_Migrate-sqlite-to-mysql.md` for how to migrate existing data over to MariaDB

</details>

<details>
<summary>PVE6 Zigbee2MQTT LXC</summary>

<h1 align="center" id="heading"> Proxmox PVE6 Zigbee2MQTT LXC Container </h1>

To create a new Proxmox 6 [Zigbee2MQTT](https://www.zigbee2mqtt.io/) LXC Container, run the following from Proxmox web shell.

```
bash -c "$(wget -qLO - https://raw.githubusercontent.com/simeonpashley/Proxmox/main/pve6_zigbee2mqtt_container.sh)"
```

<h3 align="center" id="heading">:zap: Default Settings:  1GB RAM - 4GB Storage - 2vCPU :zap:</h3>
 
Determine the location of your adapter (Run in the zigbee2mqtt console)
```
ls -l /dev/serial/by-id
```
Example Output: ```lrwxrwxrwx 1 root root 13 Jun 19 17:30 usb-1a86_USB_Serial-if00-port0 -> ../../ttyUSB0```

:warning: **Before you can start Zigbee2MQTT you need to edit the [configuration.yaml](https://www.zigbee2mqtt.io/information/configuration.html)**

```
nano /opt/zigbee2mqtt/data/configuration.yaml
```

Example:

```
frontend:
  port: 9442
homeassistant: true
permit_join: false
mqtt:
  base_topic: zigbee2mqtt
  server: 'mqtt://192.168.86.224:1883'
  user: usr
  password: pwd
  keepalive: 60
  reject_unauthorized: true
  version: 4
serial:
  port: /dev/serial/by-id/usb-1a86_USB_Serial-if00-port0
advanced:
  pan_id: GENERATE
  network_key: GENERATE
  channel: 20
```

Zigbee2mqtt can be started after completing the configuration by running

```
sudo systemctl start zigbee2mqtt
```

To start Zigbee2MQTT automatically on boot

```
sudo systemctl enable zigbee2mqtt.service
```

</details>

<details>
<summary>PVE7 Zigbee2MQTT LXC</summary>

<h1 align="center" id="heading"> Proxmox PVE7 Zigbee2MQTT LXC Container </h1>

To create a new Proxmox 7 [Zigbee2MQTT](https://www.zigbee2mqtt.io/) LXC Container, run the following from Proxmox web shell.

```
bash -c "$(wget -qLO - https://raw.githubusercontent.com/simeonpashley/Proxmox/main/pve7_zigbee2mqtt_container.sh)"
```

<h3 align="center" id="heading">:zap: Default Settings:  1GB RAM - 4GB Storage - 2vCPU :zap:</h3>
 
Determine the location of your adapter (Run in the zigbee2mqtt console)
```
ls -l /dev/serial/by-id
```
Example Output: ```lrwxrwxrwx 1 root root 13 Jun 19 17:30 usb-1a86_USB_Serial-if00-port0 -> ../../ttyUSB0```

:warning: **Before you can start Zigbee2MQTT you need to edit the [configuration.yaml](https://www.zigbee2mqtt.io/information/configuration.html)**

```
nano /opt/zigbee2mqtt/data/configuration.yaml
```

Example:

```
frontend:
  port: 9442
homeassistant: true
permit_join: false
mqtt:
  base_topic: zigbee2mqtt
  server: 'mqtt://192.168.86.224:1883'
  user: usr
  password: pwd
  keepalive: 60
  reject_unauthorized: true
  version: 4
serial:
  port: /dev/serial/by-id/usb-1a86_USB_Serial-if00-port0
advanced:
  pan_id: GENERATE
  network_key: GENERATE
  channel: 20
```

Zigbee2mqtt can be started after completing the configuration by running

```
sudo systemctl start zigbee2mqtt
```

To start Zigbee2MQTT automatically on boot

```
sudo systemctl enable zigbee2mqtt.service
```

</details>

<details>
<summary>Base Debian 10 LXC</summary>

<h1 align="center" id="heading"> Proxmox Debian 10 LXC Container </h1>

To create a new Proxmox Debian 10 (curl. sudo, auto login) LXC Container, run the following in the Proxmox web shell.

```
bash -c "$(wget -qLO - https://raw.githubusercontent.com/simeonpashley/Proxmox/main/debian10_container.sh)"
```

<h3 align="center" id="heading">:zap: Default Settings:  512MiB RAM - 2GB Storage - 1vCPU :zap:</h3>

After the script completes, If you're dissatisfied with the default settings, click on the LXC, then on the **_Resources_** tab and change the **_Memory_** and **_Cores_** settings to what you desire. Changes are immediate.

</details>

<details>
<summary>Base Debian 11 LXC</summary>

<h1 align="center" id="heading"> Proxmox Debian 11 LXC Container </h1>

To create a new Proxmox Debian 11 (curl. sudo, auto login) LXC Container, run the following in the Proxmox web shell.

```
bash -c "$(wget -qLO - https://raw.githubusercontent.com/simeonpashley/Proxmox/main/debian11_container.sh)"
```

<h3 align="center" id="heading">:zap: Default Settings:  512MiB RAM - 2GB Storage - 1vCPU :zap:</h3>

After the script completes, If you're dissatisfied with the default settings, click on the LXC, then on the **_Resources_** tab and change the **_Memory_** and **_Cores_** settings to what you desire. Changes are immediate.

</details>
