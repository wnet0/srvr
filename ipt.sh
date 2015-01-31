#IP1=''
#IP2=''
#IP3=''
#IP4=''
#IP5=''
#IP=''
#SIP=''
IPTABLES="iptables -v "

$IPTABLES -F
$IPTABLES -X
$IPTABLES -t nat -F
$IPTABLES -t nat -X
$IPTABLES -t mangle -F
$IPTABLES -t mangle -X
$IPTABLES -t raw -F
$IPTABLES -t raw -X


$IPTABLES -P INPUT DROP
$IPTABLES -P FORWARD DROP
$IPTABLES -P OUTPUT ACCEPT


$IPTABLES -N TCP
$IPTABLES -N TCPACC
$IPTABLES -N TCPNEW
$IPTABLES -N UDP
$IPTABLES -N UDPACC
$IPTABLES -N ICM
$IPTABLES -N ICMACC
$IPTABLES -N BADDRP


$IPTABLES -A OUTPUT -m conntrack --ctstate INVALID -j BADDRP


$IPTABLES -A INPUT -i lo -j ACCEPT
$IPTABLES -A INPUT -m conntrack --ctstate INVALID -j BADDRP
$IPTABLES -A INPUT -f -j BADDRP #IPV4 ONLY

$IPTABLES -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

$IPTABLES -A INPUT -p icmp -j ICM
$IPTABLES -A INPUT -p tcp -j TCP
$IPTABLES -A INPUT -p udp -j UDP

$IPTABLES -A INPUT -j LOG --log-prefix 'DROP INPUT: '
$IPTABLES -A INPUT -j DROP


$IPTABLES -A BADDRP -j LOG --log-prefix 'DROP BAD: '
$IPTABLES -A BADDRP -j DROP


$IPTABLES -A TCP -p tcp --syn -m conntrack --ctstate NEW -j TCPNEW #-m limit --limit 50/second
$IPTABLES -A TCP -p tcp -m tcp --tcp-flags RST RST -j TCPACC #-m limit --limit 2/second -limit-burst 2
$IPTABLES -A TCP -j LOG --log-prefix 'DROP TCP: '
$IPTABLES -A TCP -j DROP

#$IPTABLES -A TCPNEW -p tcp -d $IP1 --dport 22 -j TCPACC #ssh
#$IPTABLES -A TCPNEW -p tcp -d $IP1 --dport 22622 -j TCPACC #ssh
$IPTABLES -A TCPNEW -j LOG --log-prefix 'DROP TCPNEW: '
$IPTABLES -A TCPNEW -j DROP

$IPTABLES -A TCPACC -j LOG --log-prefix 'ACCEPT TCPNEW: '
$IPTABLES -A TCPACC -j ACCEPT


# Accepting ping (icmp-echo-request) can be nice for diagnostic purposes.
# However, it also lets probes discover this host is alive.
# This sample accepts them within a certain rate limit:
$IPTABLES -A ICM -p icmp --icmp-type 8 -j ICMACC #-m limit --limit 5/second

$IPTABLES -A ICM -j LOG --log-prefix 'DROP ICM: '
$IPTABLES -A ICM -j DROP

$IPTABLES -A ICMACC -j LOG --log-prefix 'ACCEPT ICM: '
$IPTABLES -A ICMACC -j ACCEPT


$IPTABLES -A UDP -j LOG --log-prefix 'DROP UDP: '
$IPTABLES -A UDP -j DROP

$IPTABLES -A UDPACC -j LOG --log-prefix 'ACCEPT UDP: '
$IPTABLES -A UDPACC -j ACCEPT
