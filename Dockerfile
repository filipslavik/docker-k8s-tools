FROM python:3.9-alpine3.12

ARG DEVSPACE_RELEASE_VERSION=v5.11.0
ARG KUBECTL_RELEASE_VERSION=v1.21.0

RUN set -x \
	&& apk add --update-cache \
		bash \
		ca-certificates \
		openssl \
		curl \
		tar \
		busybox-extras \
	&& pip install awscli \
	&& rm -rf /root/.cache/pip \
	# install kubectl 
	&& curl -LO "https://dl.k8s.io/release/$KUBECTL_RELEASE_VERSION/bin/linux/amd64/kubectl" \
	&& install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl \
	&& rm kubectl \
	# install devspace (https://devspace.sh/)
	&& curl -L -o devspace https://github.com/loft-sh/devspace/releases/download/$DEVSPACE_RELEASE_VERSION/devspace-linux-arm64 \
	&& install -o root -g root -m 0755 devspace /usr/local/bin/devspace \
	&& rm devspace \
	# install helm
	&& curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 \
	&& chmod 700 get_helm.sh \
	&& ./get_helm.sh \
	&& rm get_helm.sh
	

