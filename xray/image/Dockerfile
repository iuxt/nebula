FROM alpine:latest
ADD build_install.sh /
RUN /build_install.sh
RUN apk add nginx
ADD fallback.conf /etc/nginx/http.d/default.conf
CMD ["nginx", "&&", "/app/xray", "run", "-c", "/app/config.json"]
