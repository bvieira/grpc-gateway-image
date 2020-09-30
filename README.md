# GRPC Gateway docker image

## Docker

build image

```bash
docker build -t grpc-gateway  .
```

bash entrypoint

```bash
docker run -it -v $(pwd)/proto:/proto --entrypoint bash  grpc-gateway
```

create gateway

```bash
docker run -it -v $(pwd)/proto:/proto -v $(pwd)/output:/output grpc-gateway /proto/simple_message.proto
```
