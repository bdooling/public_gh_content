#!/usr/bin/env python3 -tt
#-*- coding: UTF-8 -*-

"""
v0.4.1: fixed FPs with individually listed filtered/closed ports in IP6 output. Overall, functional with no known major bugs at this point - but still ugly as sin..
"""

import sys
import os
from libnmap.parser import NmapParser  # ref. https://libnmap.readthedocs.io/
import xmltodict  # ref. https://github.com/martinblech/xmltodict

# in case someone tries to run this in Python v2.x:
try: 
    input = raw_input
except:
    pass

# v4results = input("Specify the location of Nmap XML file containing IPv4 scan results (full path): ")  # to replace with CLI argument..
# v6results = input("Specify the location of Nmap XML file containing IPv6 scan results (full path): ")  # ""

v4results = sys.argv[1]  # to convert to argparse..
v6results = sys.argv[2]  # ""

if os.path.exists(sys.argv[3]):
    os.remove(sys.argv[3])
else:
    print("The output files does not yet exist; Ok..")

# started out parsing nmap xml with NmapParser...:
nmapv4_report = NmapParser.parse_fromfile(v4results)

# switched to parsing the v6 output file with xmltodict b/c NmapParser was confusing.. (and to get experience with different approach):
v6xml = open(v6results,"r")
v6results = xmltodict.parse(v6xml.read())

for eachv4host in nmapv4_report.hosts:
    hostv4ports = eachv4host.get_open_ports()
    hostnamelist = eachv4host.hostnames
    if len(hostnamelist) != "1":
        # print("Entry has more than one hostname - grabbing the first one..")
        hostv4name = "".join(hostnamelist[0].strip("."))  # assume the orig / user-specified fqdn (rather than ptr record) is always returned first..
    else:
        hostv4name = "".join(hostnamelist).strip(".")
    # print(hostv4name)
    v4portset = set()
    for eachv4port in hostv4ports:
        # print(eachv4port)
        v4portset.add(eachv4port[0])
    for eachv6host in v6results['nmaprun']['host']:
        match = False
        v6portset = set()
        hostv6nameornames = eachv6host['hostnames']['hostname']
        if type(hostv6nameornames) == list:
            # print("Hostnames are in a list..: ",hostv6name)  # similar to the issue presented with multiple hostnames for IPv4..
            hostv6name = hostv6nameornames[0]['@name'].strip(".")
        else:
            hostv6name = eachv6host['hostnames']['hostname']['@name'].strip(".")
        # print(hostv6name)
        if hostv4name == hostv6name:
            match = True
            # print("We have a match!: ",hostv4name,hostv6name)
            hostv6ports = eachv6host['ports']
            # print(hostv6ports)
            try:
                for eachv6port in hostv6ports['port']:
                    try:
                        if (eachv6port['state']['@state']) == "open":
                            print("Open IPv6 port..")  # for troubleshooting purposes  # would prefer to comment this out - but causes an exception if no contents in this portion of the if statement... ??
                        else:
                            break
                    except TypeError:
                        # print("This likely means only one port open on this system.. ") # was causing an error b/c the OrderedDict for each port was not contained in a list as when there are multiple ports open  # note there also appears to be a bug that results in this message being printed four times - however, low priority / non-impacting..  # in hindsight, might've been easier to solve these type of issues by just pulling everything into tuples, and attempting to extract by index from there..
                        v6portstatelist = []
                        v6portstatelist = [(hostv6ports['state'])]
                        for eachv6portstate in v6portstatelist:
                            if (eachv6portstate['@state']) == "open":
                                print("Open IPv6 port..")  # for troubleshooting purposes  # would prefer to comment this out - but causes an exception if no contents in this portion of the if statement... ??
                            else:
                                break
                    try:
                        # type(eachv6port['@portid'])  # for troubleshooting purposes
                        # print(eachv6port['@portid']) # ""
                        v6portset.add(int(eachv6port['@portid']))
                    except TypeError:
                        # print("This likely means only one port open on this system.. ") # was causing an error b/c the OrderedDict for each port was not contained in a list as when there are multiple ports open  # note there also appears to be a bug that results in this message being printed four times - however, low priority / non-impacting..  # in hindsight, might've been easier to solve these type of issues by just pulling everything into tuples, and attempting to extract by index from there..
                        v6portlist = []
                        v6portlist = [(hostv6ports['port'])]
                        for eachv6port in v6portlist:
                            try:
                                # type(eachv6port['@portid'])
                                # print(eachv6port['@portid'])
                                v6portset.add(int(eachv6port['@portid']))
                            except:
                                print("Hmmm... if this still isn't working, I'm not sure..") # but hasn't come up yet..
            except KeyError:
                # print("KeyError - This likely means no open IPv6 ports on this system.. ")
                # print("No ports open via IPv6; moving to next IPv4 hostname..")
                continue
            break
        else:
            # print("Hostname does not match; returning to 'for eachv6host' loop...")
            continue
    if match != True:
        print("Hmmm.... no matching hostname in IP6 output for",hostv4name,"...") # need to look more closely into why this occurs.. but doesn't appear to be an issue with this script..
    # print("The ports accessible via IPv4 are: ",v4portset)
    # print("The ports accessible via IPv6 are: ",v6portset)
    v4diffset = v4portset.difference(v6portset)
    # if len(v4diffset) != 0:  # uncomment if care to see ports only accessible via IPv4..
        # print("The ports accessible only via IPv4 are: ",v4diffset)
    v6diffset = v6portset.difference(v4portset)
    if len(v6diffset) != 0:
        print("Ports accessible only via IPv6 for",hostv6name,"are:",v6diffset)
        with open(sys.argv[3],"a") as fh:
            fh.write(hostv6name + " " + str(v6diffset) + "\n")