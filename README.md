# rpi-network-bridge

A script for bridging two network interfaces on a Raspberry Pi, since simple bridging methods seem to not be compatible with the RPI hardware design.

## 1. Requirements
```
# For RPI 2 or below:
sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install dnsmasq -y

# If you are using a RPI 3:
sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install rpi-update dnsmasq -y
sudo rpi-update
```

## 2. Examples
**Note:** This script does not cover setting up network interfaces. It already assumes the two interfaces you wish to bridge are already configured correctly.

For example interface configurations, look below, or do some Googling :)
### Example eth0
```
allow-hotplug eth0
iface eth0 inet static
    address 192.168.1.1
    netmask 255.255.255.0
    network 192.168.1.0
    broadcast 192.168.1.255
```

### Example wlan0
```
auto wlan0
iface wlan0 inet dhcp
     wpa-driver madwifi #realtek driver (for realtek usb adapter)
     wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf # wpa config
```
