FROM rust:1.40-slim

ENV ZOLA_VERSION=v0.9.0
ADD https://github.com/getzola/zola/releases/download/${ZOLA_VERSION}/zola-${ZOLA_VERSION}-x86_64-unknown-linux-gnu.tar.gz /tmp
RUN tar -xzvf /tmp/zola-${ZOLA_VERSION}-x86_64-unknown-linux-gnu.tar.gz -C /usr/local/cargo/bin/
RUN apt update && apt install -y vim git && rm -rf /var/lib/apt/lists/*

WORKDIR /blog
COPY . .
CMD ["zola", "serve", "--interface", "0.0.0.0"]
