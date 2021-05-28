FROM node:14-alpine
WORKDIR /app

RUN apk update && apk add --no-cache --update \
                    bash \
                    jq \
                    git \
                    openssh \
                    curl \
                    rsync


ENV PYTHONUNBUFFERED=1

RUN apk add --no-cache python3 && \
    if [ ! -e /usr/bin/python ]; then ln -sf python3 /usr/bin/python ; fi && \
    python3 -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip3 install --no-cache --upgrade pip setuptools wheel && \
    if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi

RUN wget -q https://github.com/devops-works/binenv/releases/latest/download/binenv_linux_amd64 -O binenv
RUN chmod +x binenv && \
    mv binenv /usr/local/bin && \
    binenv update && \
    binenv install binenv 0.10.0

RUN curl -sLS https://dl.get-arkade.dev | sh
RUN arkade get kubectl
RUN mv /root/.arkade/bin/kubectl /usr/local/bin/

RUN curl -sSL https://sdk.cloud.google.com | bash
ENV PATH $PATH:/root/google-cloud-sdk/bin

RUN curl -sL https://get.garden.io/install.sh | bash -s 0.12.22
RUN cp -r /root/.garden/bin/* /usr/local/bin


COPY package.json package-lock.json /app/
RUN npm install

COPY . /app

EXPOSE 8080

ENV NODE_ENV development

CMD ["npm", "start"]
