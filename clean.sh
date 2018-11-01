#!/bin/bash

if [[ $EUID -ne 0 ]]; then
	echo "Please run this script as root" 1>&2
	exit 1
fi

echo "Cleaning source"
rm -rf dist main.spec api_secret.json build
echo "Source cleaned"
