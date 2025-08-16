FROM node:20-slim AS builder

WORKDIR /app

ENV NEXT_TELEMETRY_DISABLED=1
ENV TURBO_TELEMETRY_DISABLE=1
ENV TURBO_REMOTE_CACHE=true
ENV YARN_CACHE_FOLDER=/root/.cache/yarn
#ENV YARN_PRODUCTION=true
#ENV YARN_ENABLE_IMMUTABLE_INSTALLS=true
#ENV PUPPETEER_SKIP_DOWNLOAD=true

COPY package.json yarn.lock ./

RUN corepack enable && corepack prepare yarn --activate
RUN yarn config set --home enableTelemetry 0
RUN yarn set version stable

#RUN corepack enable && corepack prepare yarn@3.5.1 --activate
RUN --mount=type=cache,target=/root/.cache \
    --mount=type=cache,target=/app/.node \
    --mount=type=cache,target=/app/.turbo \
    yarn install --mode=skip-build
COPY . .
#RUN yarn format:check && yarn run lint && yarn run check-spelling && yarn run readme-spelling
RUN --mount=type=cache,target=/root/.cache \
    --mount=type=cache,target=/app/.node \
    --mount=type=cache,target=/app/.turbo \
    (yarn install || cat /tmp/xfs-*/build.log) && \
    yarn build

EXPOSE 8004

CMD ["/usr/local/bin/npx", "-p", "@langchain/langgraph", "-p", "@langchain/langgraph-cli", "langgraphjs", "dev", "--port", "8004"]
