FROM ubuntu

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
  && apt-get install -y \
  tzdata curl make git build-essential lsb-release \
  libtool autotools-dev autoconf libssl-dev libboost-all-dev \
  apt-transport-https ca-certificates \
  gnupg software-properties-common \
  vim jq rsync wget netcat \
  && apt-get clean all

ARG YQ_VERSION=v4.21.1
ARG YQ_BINARY=yq_linux_amd64
ARG YQ_SHASUM=50778261e24c70545a3ff8624df8b67baaff11f759e6e8b2e4c9c781df7ea8dc
RUN wget https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/${YQ_BINARY} -O /usr/bin/yq \
  && echo $YQ_SHASUM /usr/bin/yq | sha256sum --check \
  && chmod +x /usr/bin/yq

RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add - \
  && apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
  && apt-get update && apt-get install -y terraform && apt-get clean

ARG KUBECTL_VERSION=v1.24.12
ARG KUBECTL_SHASUM=715da05c56aa4f8df09cb1f9d96a2aa2c33a1232f6fd195e3ffce6e98a50a879
RUN curl -LO https://dl.k8s.io/release/$KUBECTL_VERSION/bin/linux/amd64/kubectl \
  && echo $KUBECTL_SHASUM kubectl | sha256sum --check \
  && chmod +x ./kubectl \
  && mv ./kubectl /usr/local/bin

RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | \
  tee -a /etc/apt/sources.list.d/google-cloud-sdk.list \
  && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg \
  | apt-key --keyring /usr/share/keyrings/cloud.google.gpg  add - \
  && apt-get update -y \
  && apt-get install google-cloud-sdk -y

RUN wget -O- https://k14s.io/install.sh | bash

RUN curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
  | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
  && apt update && apt install gh
