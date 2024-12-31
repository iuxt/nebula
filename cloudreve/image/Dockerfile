FROM cloudreve/cloudreve:latest
RUN apk update \
    && apk add --no-cache tzdata mailcap \
    && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone \
    && apk del tzdata
