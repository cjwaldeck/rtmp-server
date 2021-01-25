FROM ubuntu:20.04

RUN apt update && apt install -y \
    build-essential \
    libpcre3 \
    libpcre3-dev \
    libssl-dev \
    unzip \
    curl \
    zlib1g-dev

WORKDIR /tmp
RUN mkdir nginx_install \
    && curl -SL http://nginx.org/download/nginx-1.18.0.tar.gz | tar -zxv -C nginx_install --strip-components 1 \
    && curl -SL https://github.com/sergey-dryabzhinsky/nginx-rtmp-module/archive/dev.zip --output dev.zip \
    && unzip dev.zip -d nginx_install && rm dev.zip \
    && cd nginx_install \
    && ./configure --with-http_ssl_module --add-module=nginx-rtmp-module-dev \
    && make && make install \
    && cd .. \
    && rm -rf nginx_install
WORKDIR /

COPY nginx.conf.append /tmp/.
RUN cat /tmp/nginx.conf.append >> /usr/local/nginx/conf/nginx.conf && rm /tmp/nginx.conf.append

EXPOSE 1935

# Copy config if first use
CMD if find -- "/conf" -prune -type d -empty | grep -q .; then \
        cp /usr/local/nginx/conf/* /conf/. ; \
    fi \
    && usr/local/nginx/sbin/nginx -g "daemon off;" -c /conf/nginx.conf