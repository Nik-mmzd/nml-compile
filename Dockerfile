FROM docker.io/alpine:3.21

RUN apk --no-cache add bash python3 py3-pip gcc && pip3 --no-cache-dir install --break-system-packages nml && apk del -r py3-pip

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
