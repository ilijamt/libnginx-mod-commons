#!/usr/bin/env bash

sed -i "s/bullseye; urgency/${RELEASE}; urgency/g" nginx-${NGINX_SRC_VERSION}/debian/changelog
sed -i "s/~bullseye)/~${RELEASE})/g" nginx-${NGINX_SRC_VERSION}/debian/changelog
sed -i "s/{NGINX_VERSION}/${NGINX_VERSION}~${RELEASE}/g" nginx-${NGINX_SRC_VERSION}/debian/control

cd nginx-${NGINX_SRC_VERSION}
dpkg-buildpackage -b -uc -us

