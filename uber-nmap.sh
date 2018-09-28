#!/bin/bash
# v0.0.5 - updated 20180921

datesuffix=$(date +%Y%m%d)

echo "Moving existing XML results to "-prev" filename..."
mv /home/rddisd/dockshare/uber/outputs/uber-fqdns-allIPs-tcp-all.xml /home/rddisd/dockshare/uber/outputs/uber-fqdns-allIPs-tcp-all-prev.xml

echo "Beginning scan.."
# /usr/bin/docker run -i -v /home/rddisd/dockshare/uber/outputs/:/root/dockshare local/nmapbb nmap -v --reason -Pn -n -p 0-65535 -iL /tmp/uber_domains.txt --script resolveall --script-args newtargets -sV -oA /root/dockshare/uber-fqdns-allIPs-tcp-all+sV > /var/log/cron.log 2>&1

# unfortunately omitting -sV to simply the ndiff process / output means output will not distinguish btwn tcpwrapped and accessible services...
/usr/bin/docker run -i -v /home/rddisd/dockshare/uber/outputs/:/root/dockshare local/nmapbb nmap -v --reason -Pn -n -p 0-65535 -iL /tmp/uber_domains.txt --resolve-all -oA /root/dockshare/uber-fqdns-allIPs-tcp-all > /var/log/uberbbcron.log 2>&1

echo "Copying XML results to date-formatted archive filename..."
cp /home/rddisd/dockshare/uber/outputs/uber-fqdns-allIPs-tcp-all.xml /home/rddisd/dockshare/uber/outputs/uber-fqdns-allIPs-tcp-all-"$datesuffix".xml

echo "Diffing new results against previous results, using XML format..."
/usr/local/bin/ndiff --text /home/rddisd/dockshare/uber/outputs/uber-fqdns-allIPs-tcp-all-prev.xml /home/rddisd/dockshare/uber/outputs/uber-fqdns-allIPs-tcp-all.xml > /home/rddisd/dockshare/uber/outputs/diff.txt

# check diff file (excluding header) for existence of contentsd
if [ "`cat /home/rddisd/dockshare/uber/outputs/diff.txt | grep -v "Nmap" | wc -c /home/rdooling/scan_results/Nmap/nmap-int-diff-ed.txt | cut -d " " -f1`" != "0" ] ; then

