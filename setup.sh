#!/bin/sh

if [[ $EUID -ne 0 ]]; then
	echo "Please run this script as root" 1>&2
	exit 1
fi

echo "Installing DDNS"
echo
echo "Login to cloudflare.com and choose domain you want to host the DDNS. The API keys are inside 'Overview > Domain Summary > Get your API Key > API Keys'."

# Collecting Data

read -p "Enter domain name: " -r zone_name
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
cp ddns /usr/sbin/ddns

# Finding Init Process

if [ ! -f "/sbin/launchd" ]; then
	INIT="$(readlink /sbin/init)" &> /dev/null
	if [ "$?" -ne 0 ]; then
		INIT="$(dpkg -S /sbin/init)" &> /dev/null
		if [ "$?" -ne 0 ]; then
			INIT="$(rpm -qf /sbin/init)" &> /dev/null
		fi
	fi
else
	INIT="launchd"
fi

case $(echo $INIT | sed 's/^.*\///g') in
	systemd)
		echo "Found Systemd"
		sh ./process/systemd.sh
		break
		;;
	launchd)
		echo "Found Launchd"
		break
		;;
	init.d)
		echo "Found System V"
		break
		;;
	upstart)
		echo "Found Upstart"
		break
		;;
	procd)
		echo "Found Procd"
		break
		;;
	busybox)
		echo "Found BusyBox"
		break
		;;
	*)
		echo "Init process unidentified"
		exit(1)
		;;
  esac


# Cleaning setup

pip uninstall -y pyinstaller

echo "Setup completed successfully"
