FROM node:14-alpine
WORKDIR /app

RUN apk update && apk add --no-cache --update \
                    bash \
                    jq \
                    git \
                    openssh \
                    openssl \
                    curl \
                    rsync

RUN wget -O /usr/local/bin/yq "https://github.com/mikefarah/yq/releases/download/v4.9.3/yq_linux_amd64" && \
    chmod a+x /usr/local/bin/yq

RUN npm install -g yalc

ENV PYTHONUNBUFFERED=1

RUN apk add --no-cache python3 && \
    if [ ! -e /usr/bin/python ]; then ln -sf python3 /usr/bin/python ; fi && \
    python3 -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip3 install --no-cache --upgrade pip setuptools wheel && \
    if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi

RUN curl -sSL https://sdk.cloud.google.com | bash
ENV PATH $PATH:/root/google-cloud-sdk/bin

RUN curl -sLS https://dl.get-arkade.dev | sh
RUN arkade get kubectl
RUN mv /root/.arkade/bin/kubectl /usr/local/bin/

RUN wget -q https://github.com/devops-works/binenv/releases/latest/download/binenv_linux_amd64 -O binenv
RUN chmod +x binenv && \
    mv binenv /usr/local/bin && \
    binenv update && \
    binenv install binenv 0.11.0

RUN binenv install trivy 0.18.3 && \
    mv /root/.binenv/binaries/trivy/0.18.3 /usr/local/bin/trivy && \
    chmod a+x /usr/local/bin/trivy

# GitOps dependencies
RUN apk add file

RUN pip install PyYaml

RUN binenv install helm 3.6.0 && \
mv ~/.binenv/helm /usr/local/bin/

RUN binenv install helmfile 0.139.7 && \
mv ~/.binenv/helmfile /usr/local/bin/

RUN binenv install kubeseal 0.16.0 && \
mv ~/.binenv/kubeseal /usr/local/bin/

RUN binenv install kustomize 4.4.0 && \
mv ~/.binenv/kustomize /usr/local/bin/

# Test dependencies
RUN pip install yamllint

RUN wget https://github.com/instrumenta/kubeval/releases/download/v0.16.1/kubeval-linux-amd64.tar.gz && \
tar xf kubeval-linux-amd64.tar.gz && \
mv kubeval /usr/local/bin

RUN wget https://github.com/Shopify/kubeaudit/releases/download/v0.14.2/kubeaudit_0.14.2_linux_amd64.tar.gz && \
tar xf kubeaudit_0.14.2_linux_amd64.tar.gz && \
mv kubeaudit /usr/local/bin

RUN wget https://github.com/zegl/kube-score/releases/download/v1.11.0/kube-score_1.11.0_linux_amd64.tar.gz && \
tar xf kube-score_1.11.0_linux_amd64.tar.gz && \
mv kube-score /usr/local/bin

RUN wget https://github.com/open-policy-agent/conftest/releases/download/v0.25.0/conftest_0.25.0_Linux_x86_64.tar.gz && \
tar xzf conftest_0.25.0_Linux_x86_64.tar.gz && \
mv conftest /usr/local/bin

RUN curl -sL https://get.garden.io/install.sh | bash -s 0.12.25
RUN cp -r /root/.garden/bin/* /usr/local/bin

# Other dependencies
RUN npm install -g semver semver-compare-cli

# Carvel
RUN mkdir -p /app/scripts
COPY ./scripts/install-carvel.sh /app/scripts
RUN chmod +x /app/scripts/install-carvel.sh
RUN /app/scripts/install-carvel.sh

# devops-tools app
COPY package.json package-lock.json /app/
RUN npm install

COPY . /app

EXPOSE 8080

ENV NODE_ENV development

CMD ["npm", "start"]
