# Proxmox v7

This uses an Ubuntu 22 "unprivileged" container created inn Proxmox v7.

I could *not* get a Debian11 version working.

## INSIDE PVE

The container requires access to the `tun` device

```bash
nano /etc/pve/lxc/<CT_ID>.conf 
```

append `lxc.mount.entry: /dev/net/tun dev/net/tun none bind,create=file`

```bash
chown 100000:100000 /dev/net/tun
```

## INSIDE LXC

```bash
apt-get update && apt upgrade && apt install openvpn unzip
mkdir -p ~/openvpn
wget -O/root/openvpn/openvpn.zip https://www.privateinternetaccess.com/openvpn/openvpn.zip
pushd ~/openvpn && unzip openvpn.zip && popd
cp ~/openvpn/YOUR_CHOICE.ovpn /etc/openvpn/vpn.conf
```

I could not get the IP version working but the named version worked first time.

`nano /etc/openvpn/login.txt`

login.txt format
```
username
password
```

`chmod 0600 /etc/openvpn/login.txt`

`nano /etc/openvpn/vpn.conf`

APPEND the path to the login.txt

`auth-user-pass /etc/openvpn/login.txt`

`nano /etc/default/openvpn`

uncomment `# AUTOSTART="all"`

```bash
systemctl daemon-reload
systemctl enable openvpn@vpn.service
systemctl start openvpn@vpn.service
systemctl status openvpn@vpn.service
```

verify VPN is up and running `ip a` and you should see `tun0` device

# VPN KILL SWITCH

`192.168.XX.YY` is the device IP

```bash
ufw enable
ufw default deny incoming
ufw default deny outgoing
ufw allow in on eth0 to 192.168.XX.YY from 192.168.XX.0/24
ufw allow in on tun0
ufw allow out on tun0
ufw allow out on eth0 to 192.168.XX.0/24 from 192.168.XX.YY
```


