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

import argparse
import socket
import subprocess
import signal
import sys
import re

from termcolor import colored
# Ctrl+C: Exit
def def_handler(sig, frame):
    print(colored(f"\n[!] Exit...\n", 'red'))
    sys.exit(1)

signal.signal(signal.SIGINT, def_handler)


def get_arguments():
    parser = argparse.ArgumentParser(description="Tool to change the MAC address of one network interface")
    parser.add_argument("-i", "--interface", required=True, dest="interface", help="Name of the network interface")
    parser.add_argument("-m", "--mac", required=True, dest="mac_address", help="New MAC address for the interface")

    return parser.parse_args()

def input_validation(interface, mac_address):
    # Validation of a proper input
    is_valid_mac_address = re.match(r'^([A-Fa-f0-9]{2}[:]){5}[A-Fa-f0-9]{2}$', mac_address) # validation of mac address
    
    interfaces = [i[1] for i in socket.if_nameindex()]                                      # list of interfaces
    is_valid_interface = interface in interfaces                                            # validation of interface selected
    
    return is_valid_mac_address and is_valid_interface

def change_mac_address(interface, mac_address):
    # Changing MAC address
    if input_validation(interface, mac_address):
        subprocess.run(["ifconfig", interface, "down"])
        subprocess.run(["ifconfig", interface, "hw", "ether", mac_address])
        subprocess.run(["ifconfig", interface, "up"]) 

        print(colored(f"\n[+] MAC address has been succesfully changed\n", 'green'))
    else:
        print(colored(f"\n[!] The introduced data is not correct\n", 'red'))

def main():
    args = get_arguments()
    change_mac_address(args.interface, args.mac_address)

if __name__ == '__main__':
    main()
