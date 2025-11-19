FROM alpine:3.22 AS build_image

ARG KUBECTL_RELEASE_VERSION=v1.27.16
ARG DEVSPACE_RELEASE_VERSION=v5.18.5
ARG DEVSPACE_6_RELEASE_VERSION=v6.3.18
ARG HELM_RELEASE_VERSION=v3.19.2
ARG AWSCLI_RELEASE_VERSION=1.40.41

RUN set -x \
	&& apk add --no-cache \
	ca-certificates \
	openssl \
	tar \
	curl \
	bash \
	python3 \
	# install aws-cli
	&& curl -fsSL -o "awscli-bundle.zip" "https://s3.amazonaws.com/aws-cli/awscli-bundle-${AWSCLI_RELEASE_VERSION}.zip" \
	&& unzip awscli-bundle.zip \
	&& ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws \
	# install kubectl 
	&& curl -fsSL -o kubectl "https://dl.k8s.io/release/$KUBECTL_RELEASE_VERSION/bin/linux/amd64/kubectl" \
	&& install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl \
	# install devspace 5.x (https://devspace.sh/)
	&& curl -fsSL -o devspace5 https://github.com/loft-sh/devspace/releases/download/$DEVSPACE_RELEASE_VERSION/devspace-linux-amd64 \
	&& install -o root -g root -m 0755 devspace5 /usr/local/bin \
	# install devspace 6.x (https://devspace.sh/)
	&& curl -fsSL -o devspace6 "https://github.com/loft-sh/devspace/releases/download/$DEVSPACE_6_RELEASE_VERSION/devspace-linux-amd64" \
	&& install -c -m 0755 devspace6 /usr/local/bin \
	# install helm
	&& curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 \
	&& chmod 700 get_helm.sh \
	&& ./get_helm.sh --version $HELM_RELEASE_VERSION 


FROM docker:28-cli

# install buildx plugin
COPY --from=docker/buildx-bin:0.29.1 /buildx /usr/libexec/docker/cli-plugins/docker-buildx

# copy artificates from build_image
COPY --from=build_image /usr/local/bin/kubectl /usr/local/bin/
COPY --from=build_image /usr/local/bin/devspace5 /usr/local/bin/
COPY --from=build_image /usr/local/bin/devspace6 /usr/local/bin/
COPY --from=build_image /usr/local/bin/helm /usr/local/bin/
COPY --from=build_image /usr/local/bin/aws /usr/local/bin/
COPY --from=build_image /usr/local/aws /usr/local/aws

ENV PATH="/opt/venv/bin:$PATH"

RUN set -x \
	&& apk add --no-cache \
	python3 \
	bash \
	curl \
	tar \
	&& ln -s /usr/local/bin/devspace5 /usr/local/bin/devspace
