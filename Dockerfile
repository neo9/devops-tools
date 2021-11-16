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

RUN curl -sL https://get.garden.io/install.sh | bash -s 0.12.25
RUN cp -r /root/.garden/bin/* /usr/local/bin

COPY package.json package-lock.json /app/
RUN npm install

COPY . /app

EXPOSE 8080

ENV NODE_ENV development

CMD ["npm", "start"]
