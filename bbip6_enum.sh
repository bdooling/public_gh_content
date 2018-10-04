#!/bin/bash
# v0.0.3 - updated 20181001

datesuffix=$(date +%Y%m%d)

cd /home/rddisd/share/bbip6/

mv arkadiyt-domains.txt arkadiyt-domains-prev.txt

wget "https://raw.githubusercontent.com/arkadiyt/bounty-targets-data/master/data/domains.txt" -O /home/rddisd/share/bbip6/arkadiyt-domains.txt

diff /home/rddisd/share/bbip6/arkadiyt-domains.txt /home/rddisd/share/bbip6/arkadiyt-domains-prev.txt > /home/rddisd/share/bbip6/domains-diff.txt

curl -s --user 'api:dd6a48a14c1756f6c10925f0debb4fa9-b0aac6d0-91e867e2' \
    https://api.mailgun.net/v3/sandboxeaa0044743824f2a9c3bff93f2a0384f.mailgun.org/messages \
        -F from='Mailgun Sandbox <postmaster@sandboxeaa0044743824f2a9c3bff93f2a0384f.mailgun.org>' \
        -F to='Bob Dooling <rdd@disdefenders.com>' \
        -F subject='BB domain diff results' \
        -F text="$(cat /home/rddisd/share/bbip6/domains-diff.txt)"

# trying massdns-v0.2 to avoid additional records (by default) and authority records ('-a') in output:
/usr/bin/docker run -i -v /home/rddisd/share/bbip6/:/root/share local/massdns0.2 /opt/massdns-0.2/bin/massdns -l /root/share/massdns-0.2_errors.log -6 -t AAAA -r /opt/massdns-0.2/resolvers.txt -a -w /root/share/domains-aaaa-massdns-0.2.txt /root/share/arkadiyt-domains.txt
# /usr/bin/docker run -i -v /home/rddisd/share/bbip6/:/root/share local/massdns /opt/massdns/bin/massdns -l /root/share/massdns_errors.log -o F -t AAAA -r /opt/massdns/lists/resolvers.txt -w /root/share/domains-aaaa-massdns.txt /root/share/arkadiyt-domains.txt

cp /home/rddisd/share/bbip6/domains-aaaa-massdns-0.2.txt /home/rddisd/share/bbip6/domains-aaaa-massdns-0.2-"$datesuffix".txt
# cp /home/rddisd/share/bbip6/domains-aaaa-massdns.txt /home/rddisd/share/bbip6/domains-aaaa-massdns-"$datesuffix".txt

mv /home/rddisd/share/bbip6/domains-aaaa-ips-u.txt /home/rddisd/share/bbip6/domains-aaaa-ips-u-prev.txt

# updated 20181001 to exclude many common CDNs, registrars, major hosting providers, name servers, and established companies from the list of domains to resolve (due to frequently changing IP6 addresses (particularly for CDNs et al):
cat /home/rddisd/share/bbip6/domains-aaaa-massdns-0.2.txt | grep -E "IN\s+AAAA" | grep -v "]:53" | grep -v -E "cloudfront\.net|cloudflare\.com|akam\.net|root-servers\.net|gov-servers\.net|cloud\.gov|akamaiedge\.net|fastly\.net|yahoodns\.net|gtld-servers\.net|googlehosted\.com|gtld-servers\.net|ca-servers\.ca|awsdns" | grep -v -E "prodaa\.netflix\.com|dropbox-dns\.com|ns1|ns2|ns3|de\.net|nic\.dk|nstld\.com|sgnic\.sg" | grep -E "(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))" | awk -F\  '{print $NF}' | sort -u > /home/rddisd/share/bbip6/domains-aaaa-ips-u.txt
# cat /home/rddisd/share/bbip6/domains-aaaa-massdns.txt | grep "IN AAAA" | grep -v -E "cloudfront\.net|cloudflare\.com|akam\.net|root-servers\.net|gov-servers\.net|cloud\.gov|akamaiedge\.net|fastly\.net|yahoodns\.net|gtld-servers\.net|googlehosted\.com|gtld-servers\.net|ca-servers\.ca|awsdns" | grep -v -E "prodaa\.netflix\.com|dropbox-dns\.com|ns1|ns2|ns3|de\.net|nic\.dk|nstld\.com|sgnic\.sg" | grep -E "(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))" | awk -F\  '{print $NF}' | sort -u > /home/rddisd/share/bbip6/domains-aaaa-ips-u.txt

cp /home/rddisd/share/bbip6/domains-aaaa-ips-u.txt /home/rddisd/share/bbip6/domains-aaaa-ips-u-"$datesuffix".txt

diff /home/rddisd/share/bbip6/domains-aaaa-ips-u.txt /home/rddisd/share/bbip6/domains-aaaa-ips-u-prev.txt > /home/rddisd/share/bbip6/aaaa_ips-diff.txt

echo "Moving existing TCP XML results to "-prev" filename..."
mv /home/rddisd/share/bbip6/domains-ip6-tcp-26k.xml /home/rddisd/share/bbip6/domains-ip6-tcp-26k-prev.xml

/usr/local/bin/nmap -v -Pn -n --reason -6 --top-ports 26000 -iL /home/rddisd/share/bbip6/domains-aaaa-ips-u.txt -oA /home/rddisd/share/bbip6/domains-ip6-tcp-26k > /var/log/ip6_tcp_scan.log 2>&1

echo "Copying TCP XML results to date-formatted archive filename..."
cp /home/rddisd/share/bbip6/domains-ip6-tcp-26k.xml /home/rddisd/share/bbip6/domains-ip6-tcp-26k-"$datesuffix".xml

echo "Diffing new TCP results against previous results, using XML format..."
/usr/local/bin/ndiff --text /home/rddisd/share/bbip6/domains-ip6-tcp-26k-prev.xml /home/rddisd/share/bbip6/domains-ip6-tcp-26k.xml > /home/rddisd/share/bbip6/domains-ip6-tcp-26k-diff.txt

# print TCP diff file contents (excluding header & other misc):
cat /home/rddisd/share/bbip6/domains-ip6-tcp-26k-diff.txt | grep -v "Nmap" | grep -v filtered | grep -v "Not shown"

curl -s --user 'api:dd6a48a14c1756f6c10925f0debb4fa9-b0aac6d0-91e867e2' \
    https://api.mailgun.net/v3/sandboxeaa0044743824f2a9c3bff93f2a0384f.mailgun.org/messages \
        -F from='Mailgun Sandbox <postmaster@sandboxeaa0044743824f2a9c3bff93f2a0384f.mailgun.org>' \
        -F to='Bob Dooling <rdd@disdefenders.com>' \
        -F subject='BB tcp scan diff results' \
        -F text="$(cat /home/rddisd/share/bbip6/domains-ip6-tcp-26k-diff.txt | grep -v "Nmap" | grep -v filtered | grep -v "Not shown")"

echo "Moving existing UDP XML results to "-prev" filename..."
mv /home/rddisd/share/bbip6/domains-ip6-udp-10.xml /home/rddisd/share/bbip6/domains-ip6-udp-10-prev.xml

/usr/local/bin/nmap -v -Pn -n --reason -6 -sU --top-ports 10 -iL /home/rddisd/share/bbip6/domains-aaaa-ips-u.txt -oA /home/rddisd/share/bbip6/domains-ip6-udp-10 > /var/log/ip6_udp_scan.log 2>&1

echo "Copying UDP XML results to date-formatted archive filename..."
cp /home/rddisd/share/bbip6/domains-ip6-udp-10.xml /home/rddisd/share/bbip6/domains-ip6-udp-10-"$datesuffix".xml

echo "Diffing new UDP results against previous results, using XML format..."
/usr/local/bin/ndiff --text /home/rddisd/share/bbip6/domains-ip6-udp-10-prev.xml /home/rddisd/share/bbip6/domains-ip6-udp-10.xml > /home/rddisd/share/bbip6/domains-ip6-udp-10-diff.txt

# print diff file contents (excluding header & other misc):
cat /home/rddisd/share/bbip6/domains-ip6-udp-10-diff.txt | grep -v "Nmap" | grep -v filtered | grep -v "Not shown"

