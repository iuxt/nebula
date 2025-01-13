FROM ubuntu:latest
WORKDIR /vnts
ADD https://github.com/vnt-dev/vnts/releases/download/v1.2.12/vnts-x86_64-unknown-linux-musl-v1.2.12.tar.gz /vnts/
RUN tar xf vnts-x86_64-unknown-linux-musl-v1.2.12.tar.gz
CMD ["/vnts/vnts"]
