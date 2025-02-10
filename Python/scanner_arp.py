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
import sys

from termcolor import colored

def def_handler(sig, frame):
    print(colored(f"\n[!] Saliendo...", 'red'))
    sys.exit(1)

signal.signal(signal.SIGINT, def_handler)

def get_arguments():
    # Function to obtain the IP needed to explore the local hosts
    parser = argparse.ArgumentParser(description="ARP Scanner")
    parser.add_argument("-t", "--target", required=True, dest="target", help="Host / IP Rage to Scant")

    args = parser.parse_args()

    return args.target

def scan(ip):
    ## Building ARP packet
    arp_packet = scapy.ARP(pdst=ip)
    broadcast_packet = scapy.Ether(dst="ff:ff:ff:ff:ff:ff")
    arp_packet = broadcast_packet/arp_packet 

    ## Sending packet
    answered, unanswered = scapy.srp(arp_packet, timeout=1, verbose=False)
    response = answered.summary()                                           # summary of hosts
    
    if response:
        print(response)


def main():
    target = get_arguments()
    scan(target)


if __name__ == '__main__':
    main()
