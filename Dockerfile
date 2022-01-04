FROM redis:6.0-alpine3.14 as redis

FROM node:15.14.0-alpine

RUN apk add --update --no-cache \
    alpine-sdk \
    python3 \
    ca-certificates \
    libc6-compat

#ADD REDIS and REDIS USER
RUN  addgroup -S -g 1001 redis && adduser -S -G redis -u 999 redis
COPY --from=redis /usr/local/bin/redis-* /usr/bin/

COPY --chown=nobody:nobody . /var/www/

RUN \
       mv /var/www/s6-overlay-amd64-installer /tmp \
    && chmod +x /tmp/s6-overlay-amd64-installer \
    && /tmp/s6-overlay-amd64-installer / \
    && rm -f /tmp/s6-overlay-amd64-installer

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
       mv /var/www/services/01-s6-init  /etc/cont-init.d/. \
    && mv /var/www/services/01-logs-dir /etc/fix-attrs.d/. \
    && rm -Rf /var/www/services/hold \
    && mv /var/www/services/* /etc/services.d/. \
    && mv /var/www/log/* /var/log/. \
    && rm -R /var/www/services /var/www/log

ENTRYPOINT ["/init"]
#CMD [ "" ]