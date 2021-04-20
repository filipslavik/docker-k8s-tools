FROM alpine:3.12 as build_image

ARG KUBECTL_RELEASE_VERSION=v1.21.0
ARG DEVSPACE_RELEASE_VERSION=v5.11.0
ARG HELM_RELEASE_VERSION=v3.5.4
ARG AWSCLI_RELEASE_VERSION=1.19.54

## virtualenv
ENV VIRTUAL_ENV=/opt/venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

RUN set -x \
	&& apk add --no-cache \
		ca-certificates \
		openssl \
		tar \
		curl \
		bash \
		python3 \
	# install aws-cli
	&& python3 -m venv $VIRTUAL_ENV \
	&& source $VIRTUAL_ENV/bin/activate \
	&& pip install --upgrade awscli==$AWSCLI_RELEASE_VERSION \
	# install kubectl 
	&& curl -fsSL -o kubectl "https://dl.k8s.io/release/$KUBECTL_RELEASE_VERSION/bin/linux/amd64/kubectl" \
	&& install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl \
	# install devspace (https://devspace.sh/)
	&& curl -fsSL -o devspace https://github.com/loft-sh/devspace/releases/download/$DEVSPACE_RELEASE_VERSION/devspace-linux-amd64 \
	&& install -o root -g root -m 0755 devspace /usr/local/bin/devspace \
	# install helm
	&& curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 \
	&& chmod 700 get_helm.sh \
	&& ./get_helm.sh --version $HELM_RELEASE_VERSION

FROM docker:20.10.6

# copy artificates from build_image
COPY --from=build_image /usr/local/bin/kubectl /usr/local/bin/
COPY --from=build_image /usr/local/bin/devspace /usr/local/bin/
COPY --from=build_image /usr/local/bin/helm /usr/local/bin/
COPY --from=build_image /opt/venv /opt/venv

ENV PATH="/opt/venv/bin:$PATH"

RUN set -x \
	&& apk add --no-cache \
		python3 \
		bash \
		curl \
		tar

