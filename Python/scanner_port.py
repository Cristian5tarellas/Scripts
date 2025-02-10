#!/usr/bin/env python

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

import sys
import socket
import signal
import argparse

from concurrent.futures import ThreadPoolExecutor
from termcolor import colored


open_sockets = [] # list of sockets

# Ctrl+C
def def_handler(sig, frame):
# Canceling program with Ctrl+C - closing all opened sockets
    print(colored(f"\n[!] Exit...", 'red'))
    for socket in open_sockets:
        socket.close()

    sys.exit(1)

signal.signal(signal.SIGINT, def_handler) # Ctrl+C

def get_arguments():
# To get the arguments through the input / Information panel
    parser = argparse.ArgumentParser(description='Fast TCP Port Scanner - TCP connect scan')
    parser.add_argument("-t", "--target", dest="target", required=True, help="Victim target to scan -IP- (Ex: -t 192.168.1.1)")
    parser.add_argument("-p", "--port", dest="port", required=True, help="Port range to scan (Ex: -p 1-100 // -p 22,80 // -p 100)")
    options = parser.parse_args()

    return options.target, options.port

def parse_ports(ports_str):
# Depends on the string, there are different forms:
    if '-' in ports_str:
        # -p 1-100: range between 1 and 100
        start, end = map(int, ports_str.split('-'))
        return range(start, end+1)
    elif ',' in ports_str:
        # -p 22,54,80,445: list of specific ports
        return map(int, ports_str.split(','))
    else:
        # -p 80: one port
        return (int(ports_str),)

def create_socket():
# Creation of a socket
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.settimeout(15) # In case of a slow network -> increase the value
    open_sockets.append(s)

    return s

def port_scanner(host, port):
# Scanning of the socket with a specific host (target) and port.
# Output: Opened port / Closed port - Information of the service (if there is information)
    s = create_socket()             # Creation of a socket
    
    try:
        s.connect((host, port))
        s.sendall(b"HEAD / HTTP/1.0\r\n\r\n") # message to receive a response for HTTP service
        response = s.recv(1024)
        response = response.decode(errors='ignore').split('\n')[0]

        if response:
            print(colored(f"\n[+] The port {port} is opened: {response}",'green'))
        else:
            print(colored(f"\n[+] The port {port} is opened", 'green'))

    except (socket.timeout, ConnectionRefusedError):
        pass

    finally:
        open_sockets.remove(s)
        s.close()



def scann_ports(target, ports):
# Creation of threads to check ports in parallel with limited number of workers
    with ThreadPoolExecutor(max_workers=30) as executor:
        executor.map(lambda port: port_scanner(target, port), ports)

def main():
    target, ports_str = get_arguments() # Get arguments (IP-target and Ports)
    ports = parse_ports(ports_str)      # Transform the string of ports to a range of ports
    scann_ports(target, ports)          # Function to scann the ports

if __name__ == '__main__':
    main()
