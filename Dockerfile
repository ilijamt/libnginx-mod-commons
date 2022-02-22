ARG DISTRIB=debian
ARG RELEASE=bullseye

FROM ${DISTRIB}:${RELEASE}

ARG DISTRIB
ARG RELEASE
ARG DEBIAN_FRONTEND="noninteractive"
ARG TRACK=mainline

ENV TZ=UTC
ENV DISTRIB=${DISTRIB}
ENV RELEASE=${RELEASE}
ENV EMAIL="ilijamt@gmail.com"

RUN set -x && \
    apt-get update && \
    apt-get --no-install-recommends --no-install-suggests -y \
    install wget ca-certificates curl openssl gnupg2 apt-transport-https \
    unzip make libpcre3-dev zlib1g-dev build-essential devscripts \
    debhelper quilt lsb-release libssl-dev lintian uuid-dev \
    debian-archive-keyring libdistro-info-perl git-core

ARG NGINX_VERSION=1.21.6-1
ARG NGINX_SRC_VERSION=1.21.6
ARG NGINX_COMPILE_EXTRA_FLAGS=""
ARG NPS_VERSION=1.13.35.2

ENV NPS_VERSION=${NPS_VERSION}
ENV NGINX_VERSION=${NGINX_VERSION}
ENV NGINX_SRC_VERSION=${NGINX_SRC_VERSION}
ENV NGINX_COMPILE_EXTRA_FLAGS=${NGINX_COMPILE_EXTRA_FLAGS}

RUN curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor \
    | tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null

RUN echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] http://nginx.org/packages/${TRACK}/debian `lsb_release -cs` nginx" | tee /etc/apt/sources.list.d/nginx.list

RUN echo "Package: *\nPin: origin nginx.org\nPin: release o=nginx\nPin-Priority: 900\n" | tee /etc/apt/preferences.d/99nginx

RUN set -x && \
    apt-get update && \
    apt-get install -y nginx=${NGINX_VERSION}~${RELEASE}

RUN mkdir /opt/build -p

WORKDIR /opt/build

RUN wget -qO - https://github.com/apache/incubator-pagespeed-ngx/archive/v${NPS_VERSION}-stable.tar.gz | tar zxvf -
RUN wget -qO - https://nginx.org/download/nginx-${NGINX_SRC_VERSION}.tar.gz | tar zxvf -

RUN set -x && \
    mv incubator-pagespeed-ngx-${NPS_VERSION}-stable ngx_pagespeed-${NPS_VERSION}-stable && \
    cd ngx_pagespeed-${NPS_VERSION}-stable/ && \
    psol_url=https://dl.google.com/dl/page-speed/psol/${NPS_VERSION}.tar.gz && \
    [ -e scripts/format_binary_url.sh ] && psol_url=$(scripts/format_binary_url.sh PSOL_BINARY_URL) && \
    wget ${psol_url} && \
    tar -xzvf $(basename ${psol_url})

RUN set -x && \
    git clone https://github.com/google/ngx_brotli.git ngx_brotli && \
    cd ngx_brotli; git submodule update --init

RUN git clone https://github.com/nginx-modules/ngx_cache_purge

COPY debian nginx-${NGINX_SRC_VERSION}/debian

COPY build.sh /opt/build/

CMD [ "build.sh" ]