IP=''
#IP2=''
#IP3=''
#IP4=''
#IP5=''
#IP6=''
SIP=''
IPTABLES="iptables -v "
IP6TABLES="ip6tables -v "
$IPTABLES -F
$IPTABLES -X
$IPTABLES -t nat -F
$IPTABLES -t nat -X
$IPTABLES -t mangle -F
$IPTABLES -t mangle -X
$IPTABLES -t raw -F
$IPTABLES -t raw -X

$IPTABLES -P INPUT ACCEPT # set policy INPUT to accept
$IPTABLES -P FORWARD DROP # set policy FORWARD to accept
$IPTABLES -P OUTPUT ACCEPT # set policy OUTPUT to accept
$IPTABLES -N TCP
$IPTABLES -N UDP
$IPTABLES -N LD #log and drop 
$IPTABLES -N LUA
$IPTABLES -N LUD
$IPTABLES -N LTA #log and accept new
$IPTABLES -N LTR
$IPTABLES -N LUR
$IPTABLES -N LIR
$IPTABLES -N LIA

#$IPTABLES -A PREROUTING -t nat -p tcp -d $IP --dport 80 -j REDIRECT --to-port 2080
#$IPTABLES -A PREROUTING -t nat -p tcp -d $IP --dport 443 -j REDIRECT --to-port 2443
#$IPTABLES -A PREROUTING -t nat -p tcp -d $IP2 --dport 80 -j REDIRECT --to-port 3080
#$IPTABLES -A PREROUTING -t nat -p tcp -d $IP2 --dport 443 -j REDIRECT --to-port 3443
#$IPTABLES -A PREROUTING -t nat -p tcp -d $IP3 --dport 80 -j REDIRECT --to-port 4080
#$IPTABLES -A PREROUTING -t nat -p tcp -d $IP3 --dport 443 -j REDIRECT --to-port 4443

$IPTABLES -A INPUT -m conntrack --ctstate INVALID -j LD
$IPTABLES -A OUTPUT -m conntrack --ctstate INVALID -j LD

$IPTABLES -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
$IPTABLES -A INPUT -i lo -j ACCEPT
$IPTABLES -A INPUT -p icmp -m icmp --icmp-type 8 -m conntrack --ctstate NEW -j LIA

$IPTABLES -A INPUT -p udp -d $IP -m conntrack --ctstate NEW -j UDP
$IPTABLES -A INPUT -p tcp -d $IP --tcp-flags FIN,SYN,RST,ACK SYN -m conntrack --ctstate NEW -j TCP


$IPTABLES -A TCP -p tcp -s $SIP/16 -d $IP --dport 22 -j LTA #ssh

#$IPTABLES -A TCP -p tcp -m multiport --dport 80,443,2080,2443,3080,3443,4080,4443,64738 -j LTA
#$IPTABLES -A TCP -p tcp -d $IP2 -m multiport --dport 80,443,3080,3443 -j LTA
#$IPTABLES -A TCP -p tcp -d $IP3 -m multiport --dport 80,443,4080,4443 -j LTA
#$IPTABLES -A TCP -p tcp -s $SIP/16 -m multiport --dport 80,8080 -j LTA
#$IPTABLES -A TCP -p tcp -s $SIP/16 -m multiport --dport 443,8443 -j LTA
#$IPTABLES -A TCP -p tcp --dport 64738 -j LTA #murmur
$IPTABLES -A TCP -j LD


#$IPTABLES -A UDP -p udp --dport 64738 -j LUA
$IPTABLES -A UDP -j LD



$IPTABLES -A LIA -m limit --limit 60/m --limit-burst 20 -j LOG --log-prefix 'LIA: '
$IPTABLES -A LIA -j ACCEPT

$IPTABLES -A LTA -m limit --limit 60/m --limit-burst 20 -j LOG --log-prefix 'LTA: '
$IPTABLES -A LTA -j ACCEPT

$IPTABLES -A LUA -m limit --limit 60/m --limit-burst 20 -j LOG --log-prefix 'LUA: '
$IPTABLES -A LUA -j ACCEPT

$IPTABLES -A LD -m limit --limit 60/m --limit-burst 20 -j LOG --log-prefix 'LD: '
$IPTABLES -A LD -j DROP

$IPTABLES -A LTR -m limit --limit 60/m --limit-burst 20 -j LOG --log-prefix 'LTR: '
$IPTABLES -A LTR -p tcp -j REJECT --reject-with tcp-reset

$IPTABLES -A LUR -m limit --limit 60/m --limit-burst 20 -j LOG --log-prefix 'LUR: '
$IPTABLES -A LUR -j REJECT #--reject-with icmp-port-unreachable


$IPTABLES -A INPUT -j LD


$IP6TABLES -F
$IP6TABLES -X
#$IP6TABLES -t nat -F
#$IP6TABLES -t nat -X
$IP6TABLES -t mangle -F
$IP6TABLES -t mangle -X
#$IP6TABLES -t raw -F
#$IP6TABLES -t raw -X


$IP6TABLES -P INPUT ACCEPT # set policy INPUT to accept
$IP6TABLES -P FORWARD DROP # set policy FORWARD to accept
$IP6TABLES -P OUTPUT ACCEPT # set policy OUTPUT to accept
$IP6TABLES -N TCP
$IP6TABLES -N UDP
$IP6TABLES -N LIA
$IP6TABLES -N LD



$IP6TABLES -A INPUT -m conntrack --ctstate INVALID -j LD
#$IP6TABLES -A OUPUT -m conntrack --ctstate INVALID -j LD
$IP6TABLES -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
$IP6TABLES -A INPUT -i lo -j ACCEPT
$IP6TABLES -A INPUT -p icmpv6 -m icmpv6 --icmpv6-type 8 -m conntrack --ctstate NEW -j LIA

$IP6TABLES -A INPUT -p udp -m conntrack --ctstate NEW -j UDP
$IP6TABLES -A INPUT -p tcp --tcp-flags FIN,SYN,RST,ACK SYN -m conntrack --ctstate NEW -j TCP

$IP6TABLES -A TCP -j LOG --log-prefix 'TCP6: '
$IP6TABLES -A TCP -j DROP

$IP6TABLES -A UDP -j LOG --log-prefix 'UDP6: '
$IP6TABLES -A UDP -j DROP

$IP6TABLES -A LIA -j LOG --log-prefix 'LIA6: '
$IP6TABLES -A LIA -j ACCEPT

$IP6TABLES -A LD -m limit --limit 45/m --limit-burst 20 -j LOG  --log-prefix 'LD6: '
$IP6TABLES -A LD -j DROP

$IP6TABLES -A INPUT -j LD
