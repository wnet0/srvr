IP1=''
#IP2=''
#IP3=''
#IP4=''
#IP5=''
#IP6=''
SIP=''
IP6TABLES="ip6tables -v "

$IP6TABLES -F
$IP6TABLES -X
$IP6TABLES -t nat -F
$IP6TABLES -t nat -X
$IP6TABLES -t mangle -F
$IP6TABLES -t mangle -X
$IP6TABLES -t raw -F
$IP6TABLES -t raw -X


$IP6TABLES -P INPUT DROP
$IP6TABLES -P FORWARD DROP
$IP6TABLES -P OUTPUT ACCEPT


$IP6TABLES -N TCP
$IP6TABLES -N TCPACC
$IP6TABLES -N TCPNEW
$IP6TABLES -N UDP
$IP6TABLES -N UDPACC
$IP6TABLES -N ICM
$IP6TABLES -N ICMACC
$IP6TABLES -N BADDRP


$IP6TABLES -A OUTPUT -m conntrack --ctstate INVALID -j BADDRP


$IP6TABLES -A INPUT -i lo -j ACCEPT
$IP6TABLES -A INPUT -m conntrack --ctstate INVALID -j BADDRP
$IP6TABLES -A INPUT -f -j BADDRP #IPV4 ONLY

$IP6TABLES -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

$IP6TABLES -A INPUT -p icmpv6 -j ICM
$IP6TABLES -A INPUT -p tcp -j TCP
$IP6TABLES -A INPUT -p udp -j UDP

$IP6TABLES -A INPUT -j LOG --log-prefix 'DROP INPUT6: '
$IP6TABLES -A INPUT -j DROP


$IP6TABLES -A BADDRP -j LOG --log-prefix 'DROP BAD6: '
$IP6TABLES -A BADDRP -j DROP


$IP6TABLES -A TCP -p tcp --syn -m conntrack --ctstate NEW -j TCPNEW #-m limit --limit 50/second
$IP6TABLES -A TCP -p tcp -m tcp --tcp-flags RST RST -j TCPACC #-m limit --limit 2/second -limit-burst 2
$IP6TABLES -A TCP -j LOG --log-prefix 'DROP TCP6: '
$IP6TABLES -A TCP -j DROP

$IP6TABLES -A TCPNEW -p tcp -d $IP1 --dport 22 -j TCPACC #ssh
$IP6TABLES -A TCPNEW -p tcp -d $IP1 --dport 22622 -j TCPACC #ssh
$IP6TABLES -A TCPNEW -j LOG --log-prefix 'DROP TCPNEW6'
$IP6TABLES -A TCPNEW -j DROP

$IP6TABLES -A TCPACC -j LOG --log-prefix 'ACCEPT TCPNEW6'
$IP6TABLES -A TCPACC -j ACCEPT


# Accepting ping (icmp-echo-request) can be nice for diagnostic purposes.
# However, it also lets probes discover this host is alive.
# This sample accepts them within a certain rate limit:
$IP6TABLES -A ICM -p ipv6-icmp -m icmp6 --icmpv6-type 128 -j ICMACC #-m limit --limit 5/second
# ICMPv6 types 134-136 are used in NDP
$IP6TABLES -A ICM -p ipv6-icmp -m icmp6 --icmpv6-type 134 -j ICMACC
$IP6TABLES -A ICM -p ipv6-icmp -m icmp6 --icmpv6-type 135 -j ICMACC
$IP6TABLES -A ICM -p ipv6-icmp -m icmp6 --icmpv6-type 136 -j ICMACC
# ICMPv6 types 1-4 are useful even if not in an ESTABLISHED or RELATED state.
# These are accepted as defined in RFC4890 and pose no special security risk.
$IP6TABLES -A ICM -p ipv6-icmp -m icmp6 --icmpv6-type 1 -j ICMACC
$IP6TABLES -A ICM -p ipv6-icmp -m icmp6 --icmpv6-type 2 -j ICMACC
$IP6TABLES -A ICM -p ipv6-icmp -m icmp6 --icmpv6-type 3 -j ICMACC
$IP6TABLES -A ICM -p ipv6-icmp -m icmp6 --icmpv6-type 4 -j ICMACC

$IP6TABLES -A ICM -j LOG --log-prefix 'DROP ICM6: '
$IP6TABLES -A ICM -j DROP

$IP6TABLES -A ICMACC -j LOG --log-prefix 'ACCEPT ICM6: '
$IP6TABLES -A ICMACC -j ACCEPT


$IP6TABLES -A UDP -j LOG --log-prefix 'DROP UDP6: '
$IP6TABLES -A UDP -j DROP

$IP6TABLES -A UDPACC -j LOG --log-prefix 'ACCEPT UDP6: '
$IP6TABLES -A UDPACC -j ACCEPT
