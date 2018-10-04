#!/usr/bin/env python3 -tt
#-*- coding: UTF-8 -*-

"""
v0.3: Functional, albeit needs to be commented and a few minor bugs still to work out..
"""

from libnmap.parser import NmapParser
import xmltodict

nmapv4_report = NmapParser.parse_fromfile('/tmp/v4-6test/dualhomed-ip4-tcp-26k.xml')
v6xml = open("/tmp/v4-6test/dualhomed-ip6-tcp-26k.xml","r")
v6results = xmltodict.parse(v6xml.read())

for eachv4host in nmapv4_report.hosts:
    hostv4ports = eachv4host.get_open_ports()
    hostnamelist = eachv4host.hostnames
    if len(hostnamelist) != "1":
        # print("We have more than one hostname!!")
        hostv4name = "".join(hostnamelist[0].strip("."))
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
            # print("We have a list!: ",hostv6name)
            hostv6name = hostv6nameornames[0]['@name'].strip(".")
        else:
            hostv6name = eachv6host['hostnames']['hostname']['@name'].strip(".")
        # print(hostv6name)
        if hostv4name == hostv6name:
            match = True
            # print("We have a match!: ",hostv4name,hostv6name)
            # print(hostv4name,hostv6name)
            hostv6ports = eachv6host['ports']
            for eachv6port in hostv6ports['port']:
                try:
                    # type(eachv6port['@portid'])
                    # print(eachv6port['@portid'])
                    v6portset.add(int(eachv6port['@portid']))
                except TypeError:
                    # print("Only one port open on this system...!!!!!!! ")
                    v6portlist = []
                    v6portlist = [(hostv6ports['port'])]
                    for eachv6port in v6portlist:
                        try:
                            # type(eachv6port['@portid'])
                            # print(eachv6port['@portid'])
                            v6portset.add(int(eachv6port['@portid']))
                        except:
                            print("Hmmm... STILL not working?!?!?!?!")
            break
        else:
            # print("Hostname does not match; returning to 'for eachv6host' loop...")
            continue
    if match != True:
        print("Hmmm.... no matching hostname in IP6 output for",hostv4name,"...")
    # print("The ports accessible via IPv4 are: ",v4portset)
    # print("The ports accessible via IPv6 are: ",v6portset)
    v4diffset = v4portset.difference(v6portset)
    # if len(v4diffset) != 0:
        # print("The ports accessible only via IPv4 are: ",v4diffset)
    v6diffset = v6portset.difference(v4portset)
    if len(v6diffset) != 0:
        print("Ports accessible only via IPv6 for",hostv6name,"are:",v6diffset)

