FROM rust:1.30-slim

ENV GUTENBERG_VERSION=v0.4.2
ADD https://github.com/Keats/gutenberg/releases/download/${GUTENBERG_VERSION}/gutenberg-${GUTENBERG_VERSION}-x86_64-unknown-linux-gnu.tar.gz /tmp
RUN tar -xzvf /tmp/gutenberg-${GUTENBERG_VERSION}-x86_64-unknown-linux-gnu.tar.gz -C /usr/local/cargo/bin/
RUN apt update && apt install -y vim git && rm -rf /var/lib/apt/lists/*

WORKDIR /blog
COPY . .
CMD ["gutenberg", "serve", "--interface", "0.0.0.0"]
