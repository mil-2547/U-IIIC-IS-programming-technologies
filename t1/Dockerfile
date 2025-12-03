FROM alpine:latest
RUN apk add --update wine
RUN rm -rf /var/cache/apk/*
WORKDIR /app
COPY ./build/bin/app.exe .
ENTRYPOINT ["wine", "app.exe"]
