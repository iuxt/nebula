FROM alpine:latest
ADD build_install.sh /
RUN /build_install.sh
CMD ["/app/xray", "run", "-c", "/app/config.json"]
