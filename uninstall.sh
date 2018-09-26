#!/bin/bash

if [[ $EUID -ne 0 ]]; then
	echo "Please run this script as root" 1>&2
	exit 1
fi

echo "Uninstalling"
./clean.sh
systemctl stop ddns.service
systemctl disable ddns.service
rm -rf /lib/systemd/system/ddns.service /usr/sbin/ddns ./ddns
systemctl daemon-reload
pip uninstall -y requests
pip uninstall -y cloudflare
echo "Successfully ninstalled"
