#!/bin/sh

echo "------------------------------------------"
echo "username: root"

if [ -n "$ROOT_PASSWORD" ]; then
	echo "root:$ROOT_PASSWORD"|chpasswd
	echo "password: $ROOT_PASSWORD"
else
	random_password=`date +%s | sha256sum | base64 | head -c 32 ; echo`
	echo "root:$random_password"|chpasswd
	echo "password: $random_password"
fi

echo "------------------------------------------"

echo "Starting SSH server."
/usr/sbin/sshd -D -e
