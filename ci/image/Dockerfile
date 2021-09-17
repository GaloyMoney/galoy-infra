FROM ubuntu

RUN wget -O- https://carvel.dev/install.sh | bash

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
  && apt-get install -y \
  tzdata wget curl make git build-essential lsb-release \
  apt-transport-https ca-certificates \
  gnupg software-properties-common \
  vim jq rsync \
  && apt-get clean all

RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add - \
  && apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
  && apt-get update && apt-get install -y terraform && apt-get clean

RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl \
            && chmod +x ./kubectl \
            && mv ./kubectl /usr/local/bin

RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | \
  tee -a /etc/apt/sources.list.d/google-cloud-sdk.list \
  && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg \
  | apt-key --keyring /usr/share/keyrings/cloud.google.gpg  add - \
  && apt-get update -y \
  && apt-get install google-cloud-sdk -y

RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
  | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
  && apt update && apt install gh

RUN wget https://github.com/bodymindarts/cepler/releases/download/v0.6.5/cepler-x86_64-unknown-linux-musl-0.6.5.tar.gz \
  && tar -zxvf cepler-x86_64-unknown-linux-musl-0.6.5.tar.gz \
  && mv cepler-x86_64-unknown-linux-musl-0.6.5/cepler /usr/local/bin \
  && chmod +x /usr/local/bin/cepler \
  && rm -rf ./cepler-*
