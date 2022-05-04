FROM redis:6.0-alpine3.14 as redis

FROM node:15.14.0-alpine

RUN apk add --update --no-cache \
    alpine-sdk \
    python3 \
    ca-certificates \
    libc6-compat \
    xz

#ADD REDIS and REDIS USER
RUN  addgroup -S -g 1001 redis && adduser -S -G redis -u 999 redis
COPY --from=redis /usr/local/bin/redis-* /usr/bin/

COPY --chown=nobody:nobody . /var/www/

ADD https://github.com/just-containers/s6-overlay/releases/download/v3.1.0.1/s6-overlay-noarch.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz
ADD https://github.com/just-containers/s6-overlay/releases/download/v3.1.0.1/s6-overlay-x86_64.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-x86_64.tar.xz

#1.15.0
WORKDIR /var/www/auth
RUN yarn install --pure-lockfile \
    && yarn build
#1.37.2
WORKDIR /var/www/syncing-server-js
RUN NODE_OPTIONS="--max-old-space-size=2048" yarn install --pure-lockfile \
    && yarn build
#1.21.3
WORKDIR /var/www/api-gateway
RUN yarn install --pure-lockfile \
    && yarn build

RUN \
       mv /var/www/services/* /etc/s6-overlay/s6-rc.d/. \
    && mv /etc/s6-overlay/s6-rc.d/contents/* /etc/s6-overlay/s6-rc.d/user/contents.d/. \
    && mv /var/www/log/* /var/log/. \
    && chmod -R u+rwx /var/log/* \
    && rm -R /var/www/services /var/www/log /etc/s6-overlay/s6-rc.d/contents


ENTRYPOINT ["/init"]
#CMD [ "" ]