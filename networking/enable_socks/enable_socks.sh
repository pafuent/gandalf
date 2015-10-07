#!/bin/bash 

iptables_rules() {
    # Create new chain
    iptables -t nat -N REDSOCKS
    # Ignore LANs and some other reserved addresses
    iptables -t nat -$1 REDSOCKS -d 0.0.0.0/8 -j RETURN
    iptables -t nat -$1 REDSOCKS -d 10.0.0.0/8 -j RETURN
    iptables -t nat -$1 REDSOCKS -d 127.0.0.0/8 -j RETURN
    iptables -t nat -$1 REDSOCKS -d 169.254.0.0/16 -j RETURN
    iptables -t nat -$1 REDSOCKS -d 163.33.0.0/16 -j RETURN
    iptables -t nat -$1 REDSOCKS -d 172.16.0.0/12 -j RETURN
    iptables -t nat -$1 REDSOCKS -d 192.168.0.0/16 -j RETURN
    iptables -t nat -$1 REDSOCKS -d 224.0.0.0/4 -j RETURN
    iptables -t nat -$1 REDSOCKS -d 240.0.0.0/4 -j RETURN

    # Redirect all port 80 connections to the http-relay redsocks port
    iptables -t nat -$1 REDSOCKS -p tcp --dport 80 -j REDIRECT --to-ports 12345
    # Redirect all port 443 connections to the http-connect redsocks port
    iptables -t nat -$1 REDSOCKS -p tcp --dport 443 -j REDIRECT --to-ports 12346
    # Redirect anithing else to the socks5 redsocks port
    iptables -t nat -$1 REDSOCKS -p tcp -j REDIRECT --to-ports 12347

    # Use the REDSOCKS chain for all outgoing connection in the network 
    iptables -t nat -$1 OUTPUT -p tcp -o eth0 -j REDSOCKS

    # Use the REDSOCKS chain for all outgoing connection in the vpn network
    iptables -t nat -$1 OUTPUT -p tcp -o vpn0 -j REDSOCKS

    # Redirect docker0 port 80 connections to the http-relay redsocks port
    iptables -t nat -$1 PREROUTING -i docker0 -p tcp --dport 80 -j REDSOCKS
    # Redirect docker0 port 443 connections to the http-relay redsocks port
    iptables -t nat -$1 PREROUTING -i docker0 -p tcp --dport 443 -j REDSOCKS
}

stop() {
    echo "Cleaning iptables"
    iptables_rules D
    pkill -9 redsocks
}

interrupted () {
    echo 'Interrupted, cleaning up...'
    trap - INT
    stop
    kill -INT $$
}

run() {
    trap interrupted INT
    trap terminated TERM
    iptables_rules A
    /usr/sbin/redsocks -c redsocks.conf
}

terminated () {
    echo 'Terminated, cleaning up...'
    trap - TERM
    stop
    kill -TERM $$
}

case "$1" in
    stop )  stop ;;
    * )     run ;;
esac
