#!/bin/bash
# v0.0.1 - updated 20181001

datesuffix=$(date +%Y%m%d)

cd /home/rddisd/share/bbip6/

wget "https://raw.githubusercontent.com/arkadiyt/bounty-targets-data/master/data/domains.txt" -O /home/rddisd/share/bbip6/arkadiyt-domains-for_scanning.txt




# /usr/local/bin/nmap -v -Pn -n --reason -6 --top-ports 26000 -iL /home/rddisd/share/bbip6/domains-aaaa-ips-u.txt -oA /home/rddisd/share/bbip6/domains-ip6-tcp-26k > /var/log/ip6_tcp_scan.log 2>&1



# /usr/local/bin/nmap -v -Pn -n --reason -6 -sU --top-ports 10 -iL /home/rddisd/share/bbip6/domains-aaaa-ips-u.txt -oA /home/rddisd/share/bbip6/domains-ip6-udp-10 > /var/log/ip6_udp_scan.log 2>&1


