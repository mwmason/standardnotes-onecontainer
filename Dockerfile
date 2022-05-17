FROM redis:6.0-alpine3.15 as redis

FROM node:16-alpine3.15

RUN apk add --update --no-cache \
    alpine-sdk \
    python3 \
    ca-certificates \
    libc6-compat \
    xz

#ADD REDIS and REDIS USER
RUN  addgroup -S -g 1001 redis && adduser -S -G redis -u 999 redis
COPY --from=redis /usr/local/bin/redis-* /usr/bin/

ADD https://github.com/just-containers/s6-overlay/releases/download/v3.1.0.1/s6-overlay-noarch.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz
ADD https://github.com/just-containers/s6-overlay/releases/download/v3.1.0.1/s6-overlay-x86_64.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-x86_64.tar.xz

ADD https://github.com/standardnotes/auth/archive/refs/tags/1.44.1.tar.gz /var/www/
RUN tar -xzf /var/www/auth-1.44.1.tar.gz \
    && mv /var/www/auth-1.44.1 /var/www/auth

ADD https://github.com/standardnotes/syncing-server-js/archive/refs/tags/1.52.1.tar.gz /var/www/
RUN tar -xzf /var/www/syncing-server-js-1.52.1.tar.gz \
    && mv /var/www/syncing-server-js-1.52.1 /var/www/syncing-server-js

ADD https://github.com/standardnotes/api-gateway/archive/refs/tags/1.37.0.tar.gz /var/www/
RUN tar -xzf /var/www/api-gateway-1.37.0.tar.gz \
    && mv /var/www/api-gateway-1.37.0 /var/www/api-gateway

WORKDIR /var/www/auth
RUN yarn install --pure-lockfile \
    && yarn build
    
WORKDIR /var/www/syncing-server-js
RUN NODE_OPTIONS="--max-old-space-size=2048" yarn install --pure-lockfile \
    && yarn build

WORKDIR /var/www/api-gateway
RUN yarn install --pure-lockfile \
    && yarn build

COPY --chown=nobody:nobody ./services /etc/s6-overlay/s6-rc.d/
COPY --chown=nobody:nobody ./log /var/log/

RUN \  
       find /etc/s6-overlay/s6-rc.d/. -name run | xargs chmod u+x \
    && find /etc/s6-overlay/s6-rc.d/. -name check | xargs chmod u+x \
    && mv /etc/s6-overlay/s6-rc.d/contents/* /etc/s6-overlay/s6-rc.d/user/contents.d/. \
    && chmod -R u+rwx /var/log/* \
    && rm -R /tmp/*.xz /tmp/*.gz /etc/s6-overlay/s6-rc.d/contents


ENTRYPOINT ["/init"]
