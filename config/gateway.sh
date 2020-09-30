#!/bin/bash

PROTO=$1
PROJECT_DIR=/gateway
OUTPUT=/output

CORE_PACKAGE=core
PROJECT=gateway
CONFIG=/config
INCLUDE="$CONFIG/include"
TEMPLATE="$CONFIG/template"

genStubs() {
    local proto=$1
    local output=$2

    mkdir -p "$output"
    protoc -I $INCLUDE -I /proto/ --go_out "$output" --go_opt plugins=grpc --go_opt paths=source_relative $proto
}

genGateway() {
    local proto=$1
    local output=$2

    mkdir -p "$output"
    protoc -I $INCLUDE -I /proto/ --grpc-gateway_out=logtostderr=true,generate_unbound_methods=true,paths=source_relative:"$output" $proto
}

genSwagger() {
    local proto=$1
    local output=$2

    mkdir -p $output
    protoc -I $INCLUDE -I /proto/ --openapiv2_out="$output" $proto
}


genMain() {
    local include=$1
    local service=$2
    local output=$3

    sed "s/##INCLUDE##/$include/" "$TEMPLATE/main.go.tpl" | sed "s/##SERVICE##/$service/" > "$output/main.go"
}

buildGateway() {
    cd $PROJECT_DIR
    go mod init gateway
    go build -o "$OUTPUT/gateway"
    cd -
}

serviceName() {
    local proto=$1

    grep "service" $proto | awk '{print $2}' | head -n1
}

execute() {
    echo "generating stubs"
    genStubs $PROTO "$PROJECT_DIR/$CORE_PACKAGE"

    echo "generating gateway"
    genGateway $PROTO "$PROJECT_DIR/$CORE_PACKAGE"

    echo "generating main"
    local service=$(serviceName $PROTO)
    genMain "$PROJECT\/$CORE_PACKAGE" $service "$PROJECT_DIR"

    echo "generating swagger"
    genSwagger $PROTO $OUTPUT

    echo "build gateway"
    buildGateway
}

execute