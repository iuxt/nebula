FROM ubuntu:latest
WORKDIR /vnts
ADD https://github.com/vnt-dev/vnts/releases/download/v1.2.12/vnts-x86_64-unknown-linux-musl-v1.2.12.tar.gz /vnts/
ADD entrypoint.sh /
RUN tar xf vnts-x86_64-unknown-linux-musl-v1.2.12.tar.gz
CMD ["/entrypoint.sh"]
