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
import subprocess
import signal
import sys

from concurrent.futures import ThreadPoolExecutor
from termcolor import colored

# Ctrl+C: closing the program
def def_handler(sig, frame):
    print(colored(f"\n[!] Exit...", "red"))
    sys.exit(1)

signal.signal(signal.SIGINT, def_handler)

def get_arguments():
    # Obtainig IP or range of IP to scan
    parser = argparse.ArgumentParser(description="Tool to discover active hosts in a network (throught ICMP protocol)")
    parser.add_argument("-t","--target", required=True, dest="target", help="Host or range of IP address to scan (Example: 192.168.1.10 / 192.168.1.1-100")
    arg = parser.parse_args()
    
    return arg.target

def parse_target(target_str):
    # Transforming range of IPs in a list of IPs
    target_str_splitted = target_str.split('.')
    if len(target_str_splitted) == 4:
        if "-" in target_str_splitted[3]:
            start, end = target_str_splitted[3].split('-')
            return [f"{'.'.join(target_str_splitted[0:3])}.{i}" for i in range(int(start), int(end)+1)]
        else:
            return [target_str]
    else:
        print(colored(f"\n[!] Wrong IP format or the Range of IP is not valid\n",'red'))

def host_discovery(target):
    try:
        ping = subprocess.run(["ping","-c","1",target], timeout=1, stdout=subprocess.DEVNULL)
        # Active Hosts = state code is 0
        if ping.returncode == 0:
            print(colored(f"\n[+] Host {target} is active", 'green'))

    except subprocess.TimeoutExpired:
        pass

def main():
    target_str = get_arguments()         # Obtaining arguments (string)
    targets = parse_target(target_str)   # Tranforming strings to range
    
    # Scanning Hosts
    print(f"\n[+] Active Host in the network:\n")
    max_threads = 100
    with ThreadPoolExecutor(max_workers=max_threads) as executor:
        executor.map(host_discovery, targets)

if __name__ == '__main__':
    main()
