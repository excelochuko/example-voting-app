# Stage 1: Install application dependencies
ARG NODE_BASE=node:22-trixie-slim
FROM ${NODE_BASE} AS builder

WORKDIR /usr/local/app

COPY package*.json ./

RUN npm ci

COPY . .

# Stage 2: Create the runtime image
FROM ${NODE_BASE} AS runtime

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends tini && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /usr/local/lib/node_modules/npm

WORKDIR /usr/local/app

COPY --from=builder /usr/local/app /usr/local/app

ENV PORT=80
EXPOSE 80

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["node", "server.js"]
