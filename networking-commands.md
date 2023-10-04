# Set static IP Address
```
# check NIC recognised
lspci -v

# Check kernel has loaded the driver
dmesg | grep atl1

# Show Interfaces
ip link show

# Show specific interface
ip link show dev ens18

# Set a hostname
hostnamectl set-hostname servername

# Set a static IP
ip addr add 10.0.0.2/24 dev ens18

# Bring an interface up or down
ip link set ens18 down
ip link set ens18 up

# Show IP addresses
ip address show

# Show routing table
ip route show

# Add default route
ip route add default via 10.0.0.1

# Add route to specific network
ip route add 192.168.2.0/24 via 192.168.2.254 dev eth0

# Delete route
ip route delete 192.168.1.0/24 dev eth0

# Delete default route
ip route delete default

# Add static DNS entry
echo "nameserver 10.0.0.1" > /etc/resolv.conf
echo "domain example.org" >> /etc/resolv.conf

# Install drill (replacement for dig)
pacman -S ldns
drill @nameserver hostname.dns.name

# Other tools
pacman -S traceroute iputils nmap gnu-netcat whois mtr
pacman -S net-tools # if you need ifconfig

```

# WIFI
```
pacman -S wireless_tools iw wpa_supplicant netctl iwd

# iw commands
iw dev
iw dev interface station dump
ip link set interface up
iw dev interface scan | less
iw dev interface connect "your_essid"

# iwctl commands
iwctl
[iwd]# device list
[iwd]# device device set-property Powered on
[iwd]# station device scan
[iwd]# station device get-networks
[iwd]# station device connect SSID


iwctl --passphrase passphrase station device connect SSID # as 1 command
```
