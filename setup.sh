#!/bin/bash

if [[ $EUID -ne 0 ]]; then
	echo "Please run this script as root" 1>&2
	exit 1
fi

echo "Installing DDNS"

# Collecting Data

read -p "Enter zone name: " -r zone_name
read -p "Enter email id: " -r email
read -p "Enter API Key: " -r token
read -p "Enter User Service Key: " -r certtoken

# Installing compiler

pip install -U pyinstaller
pip install -U requests
pip install -U cloudflare

# Creating API secret file
cat > api_secret.json << EOF
{
    "zone_name": "$zone_name",
    "email": "$email",
    "token": "$token",
    "certtoken": "$certtoken"
}
EOF

# Compiling the package


pyinstaller --noconfirm --clean --onefile \
	--hidden-import=api \
	main.py

cp ./dist/main ./ddns

# Setting up systemd service

echo "Setting up systemd service"
cp ddns /usr/sbin/ddns
cat > /lib/systemd/system/ddns.service << EOF 
[Unit]
Description=DDNS on Cloudflare
StartLimitInterval=4
After=network.target

[Service]
Type=simple
Restart=always
RestartSec=1
User=root
ExecStart=/usr/sbin/ddns '$(pwd)'

[Install]
WantedBy=multi-user.target
EOF
chmod 644 /lib/systemd/system/ddns.service
systemctl daemon-reload
systemctl enable ddns.service
systemctl start ddns.service

# Cleaning setup

pip uninstall -y pyinstaller

echo "Setup completed successfully"

systemctl status ddns.service
