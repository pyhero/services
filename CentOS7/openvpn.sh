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
iptables -t nat -A POSTROUTING -j MASQUERADE
service iptables save
systemctl enable iptables
