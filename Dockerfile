ARG BASE_VERSION
FROM ubuntu:${BASE_VERSION}

ARG BASE_VERSION
ARG UID
ARG GID
ARG USER=apt-cacher-ng
ARG OLD_UID=101
ARG OLD_GID=101
ENV ACNG_TRUNC=$ACNG_TRUNC
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# hadolint ignore=DL3008,SC2086
RUN if [ -n "$APT_PROXY" ]; then \
      echo 'Acquire::http { Proxy "'$APT_PROXY'"; }'  \
      | tee /etc/apt/apt.conf.d/01proxy \
    ;fi && \
    apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get upgrade -yq \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
      --no-install-recommends \
       apt-cacher-ng ca-certificates cron tini \
    && rm -rf /var/lib/apt/lists/* \
    && cp /etc/apt-cacher-ng/acng.conf /etc/apt-cacher-ng/acng.conf.dist \
    && if id ubuntu; then \
      userdel -rf ubuntu \
    ; fi \
    && if [ -n "$UID" ] && [ -n "$GID" ]; then \
      echo 'Setting UID:'$UID' and GID:'$GID \
      && usermod -u $UID $USER \
      && groupmod -g $GID $USER \
      && find /var -group $OLD_GID -exec chgrp -h "$USER" {} + \
      && find /var -user $OLD_UID -exec chown -h "$USER" {} + \
    ; fi \
    && chown $USER:$USER -R /etc/apt-cacher-ng \
    && chown $USER:$USER -R /var/run/apt-cacher-ng \
    && chown $USER:$USER -R /var/cache/apt-cacher-ng \
    && chown $USER:$USER -R /var/log/apt-cacher-ng \
    && touch /var/run/crond.pid \
    && chown $USER:$USER -R /var/run/crond.pid \
    && chmod u+s /usr/sbin/cron

COPY --chown=$USER:$USER etc/acng.conf /etc/apt-cacher-ng/
COPY --chown=$USER:$USER acng.sh /usr/local/bin
COPY cron.allow /etc/
USER apt-cacher-ng
EXPOSE 3142

CMD ["/usr/local/bin/acng.sh"]
ENTRYPOINT ["/usr/bin/tini", "--"]
