#!/bin/sh

cp ./process/systemd.tpl /lib/systemd/system/ddns.service
chmod 644 /lib/systemd/system/ddns.service
systemctl daemon-reload
systemctl enable ddns.service
systemctl start ddns.service
systemctl status ddns.service