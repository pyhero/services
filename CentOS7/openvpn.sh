hostnamectl set-hostname ovpn01.sensorsdata.cn

yum -y -q update --skip-broken
yum install -y -q java-1.8.0-openjdk \
                make cmake gcc \
                screen lrzsz rsync ntp \
                tcpdump iftop traceroute net-snmp-utils sysstat bind-utils sl sipcalc telnet jwhois tree mtr \
                openssl openssl-devel mhash mhash-devel compat-libstdc++-33 \
                python git vim xinetd sshpass net-tools

systemctl start ntpd
systemctl enable ntpd
reboot

yum -y install easy-rsa openssh-server lzo openssl openssl-devel openvpn openvpn-auth-ldap

cp -r /usr/share/easy-rsa /etc/openvpn/
https://www.techlear.com/2019/04/16/how-to-install-openvpn-server-and-client-with-easy-rsa-3-on-centos-7/

systemctl -f enable openvpn@server
systemctl start openvpn@server
echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.conf
echo 'net.netfilter.nf_conntrack_max = 655350' >> /etc/sysctl.conf
sysctl -p

yum install -y iptables-services
iptables -t nat -A POSTROUTING -s 192.168.0.0/16 -j MASQUERADE
service iptables save
systemctl enable iptables

# rd
iptables -t filter -N RD
iptables -t filter -F RD
iptables -t filter -A RD -s 192.168.72.0/21 -d 10.120.0.0/16 -o eth0 -p tcp -m tcp --dport 22 -j ACCEPT
iptables -t filter -A RD -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -t filter -A FORWARD -s 192.168.72.0/21 -j RD
iptables -t filter -A FORWARD -s 192.168.72.0/21 -d 10.0.0.0/8 -o eth0 -p tcp -m tcp --dport 22 -j REJECT --reject-with icmp-port-unreachable

# admin
iptables -t filter -N ADMIN
iptables -t filter -F ADMIN
iptables -t filter -A ADMIN -s 192.168.80.0/21 -d 10.10.96.80/32 -o eth0 -p tcp -m tcp --dport 443 -j ACCEPT
iptables -t filter -A ADMIN -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -t filter -A FORWARD -s 192.168.80.0/21 -j ADMIN
iptables -t filter -A FORWARD -s 192.168.80.0/21 -o eth0 -j REJECT --reject-with icmp-host-prohibited
