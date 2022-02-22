NPS_VERSION=$(shell curl -s https://api.github.com/repos/apache/incubator-pagespeed-ngx/tags | grep "name" | grep "stable" | head -1 | sed -n "s/^.*v\(.*\)-stable.*$$/\1/p")
NGINX_DEB_VERSION=$(shell curl -s http://nginx.org/packages/mainline/debian/pool/nginx/n/nginx/ |grep '"nginx_' | sed -n "s/^.*\">nginx_\(.*\)\~.*$$/\1/p" |sort -Vr |head -1)

test:
	@echo ${NPS_VERSION}
	@echo ${NGINX_DEB_VERSION}

