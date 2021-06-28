FROM ubuntu

RUN wget -O- https://carvel.dev/install.sh | bash

RUN apt-get update && apt-get install -y \
  make jq curl tree

RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add - \
  && apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
  && apt-get update && apt-get install -y terraform

RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl \
            && chmod +x ./kubectl \
            && mv ./kubectl /usr/local/bin

RUN git clone https://github.com/bats-core/bats-core.git \
            && cd bats-core \
            && ./install.sh /usr/local

RUN export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)" && \
      echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
      curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
      apt-get update && apt-get -y install google-cloud-sdk && apt-get clean

