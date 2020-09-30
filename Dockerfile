FROM golang:1.15-alpine3.12

RUN mkdir -p "/gateway/core" && mkdir "/config"
WORKDIR /gateway

RUN apk --update --no-cache add bash git gawk wget ca-certificates 

RUN set -ex && apk --update --no-cache add \
    protoc~=3.13 \
    --repository=http://dl-cdn.alpinelinux.org/alpine/edge/main

RUN go get github.com/golang/protobuf/protoc-gen-go

RUN wget https://github.com/grpc-ecosystem/grpc-gateway/releases/download/v2.0.0-beta.5/protoc-gen-grpc-gateway-v2.0.0-beta.5-linux-x86_64 \
    -O /go/bin/protoc-gen-grpc-gateway && chmod +x /go/bin/protoc-gen-grpc-gateway

RUN wget https://github.com/grpc-ecosystem/grpc-gateway/releases/download/v2.0.0-beta.5/protoc-gen-openapiv2-v2.0.0-beta.5-linux-x86_64 \
    -O /go/bin/protoc-gen-openapiv2 && chmod +x /go/bin/protoc-gen-openapiv2

ADD config/ /config/

ENTRYPOINT [ "/config/gateway.sh" ]
