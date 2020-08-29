FROM alpine:latest

RUN apk add --update \
    bash \
    python \
    py-pip \
    curl \
    && rm -rf /var/cache/apk/*

# kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.16.3/bin/linux/amd64/kubectl
RUN chmod u+x kubectl && mv kubectl /bin/kubectl

# Root's home directory
RUN mkdir -vp /home/root
WORKDIR /home/root
