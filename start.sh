#!/bin/bash


sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config
[[ ! -z ${GATEWAY_PORTS+z} ]] && sed -ri "s/^#?GatewayPorts\s+.*/GatewayPorts ${GATEWAY_PORTS}/" /etc/ssh/sshd_config
[[ ! -z ${PASSWORD_AUTHENTICATION+z} ]] && sed -ri "s/^#?PasswordAuthentication\s+.*/PasswordAuthentication ${PASSWORD_AUTHENTICATION}/" /etc/ssh/sshd_config


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
