FROM ubuntu:jammy

ARG UID
ARG GID
ARG USER=apt-cacher-ng
ARG OLD_UID=101
ARG OLD_GID=101
ENV ACNG_TRUNC=$ACNG_TRUNC
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
       apt-cacher-ng ca-certificates tini \
    && rm -rf /var/lib/apt/lists/* \
    && cp /etc/apt-cacher-ng/acng.conf /etc/apt-cacher-ng/acng.conf.dist \
    && if [ -n "$UID" -a -n "$GID" ]; then \
      echo 'Setting UID:'$UID' and GID:'$GID \
      && usermod -u $UID $USER \
      && groupmod -g $GID $USER \
      && find /var -group $OLD_GID -exec chgrp -h "$USER" {} + \
      && find /var -user $OLD_UID -exec chown -h "$USER" {} + \
    ; fi \
    && chown $UID:$GID -R /etc/apt-cacher-ng

COPY --chown=$USER:$USER etc/* /etc/apt-cacher-ng/
COPY --chown=$USER:$USER acng.sh /usr/local/bin
USER apt-cacher-ng
EXPOSE 3142
CMD ["/usr/local/bin/acng.sh"]
ENTRYPOINT ["/usr/bin/tini", "--"]
