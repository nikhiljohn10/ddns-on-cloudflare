[Unit]
Description=DDNS on Cloudflare
StartLimitInterval=4
After=network.target

[Service]
Type=simple
Restart=always
RestartSec=1
User=root
ExecStart=/usr/sbin/ddns

[Install]
WantedBy=multi-user.target