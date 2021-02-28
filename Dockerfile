FROM ubuntu:latest

# Update and install apt cacher ng. then clean up apt cache to keep to image small
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
       apt-cacher-ng ca-certificates &&\
    rm -rf /var/lib/apt/lists/* &&\
    cp /etc/apt-cacher-ng/acng.conf /etc/apt-cacher-ng/acng.conf.debian

COPY ./acng.conf /etc/apt-cacher-ng/acng.conf
USER apt-cacher-ng
EXPOSE 3142
VOLUME ["/var/cache/apt-cacher-ng"]

CMD ["-c", "/etc/apt-cacher-ng", "ForeGround=1"]
ENTRYPOINT ["apt-cacher-ng"]
