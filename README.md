# docker-k8s-tools

A Docker image with `kubectl`, `awscli`, `devspace` and `helm` CLI tools, which makes it
suitable to be used in CI flows when interacting with k8s clusters.

## Version

- `v1.0` - initial version 

## Build new version

Build

```
$ docker build . -t docker-k8s-tools
```

Run 

```
$ docker run --rm -it docker-k8s-tools sh
```