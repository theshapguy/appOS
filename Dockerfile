ARG ELIXIR_VERSION=1.18.0
ARG OTP_VERSION=27.2
ARG UBUNTU_VERSION=20240808
# Platform is Fixed To This Because of Production Server Being In This Target Triple
ARG BUILDPLATFORM=linux/amd64
# ARG BUILDER_IMAGE="hexpm/elixir:1.18.0-erlang-27.2-ubuntu-jammy-20240808"
ARG BUILDER_IMAGE="hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-ubuntu-jammy-${UBUNTU_VERSION}"

FROM --platform=${BUILDPLATFORM} node:lts-bookworm-slim AS node
FROM --platform=${BUILDPLATFORM} python:3.12.4-bookworm AS python-build
FROM --platform=${BUILDPLATFORM} ${BUILDER_IMAGE} AS builder

# https://elixirforum.com/t/apple-silicon-and-cross-platform-docker-fails-minikube/60699
# https://archive.ph/eyUIN
ENV ERL_FLAGS="+JPperf true"

# Install Node
COPY --from=node /usr/local/bin/node /usr/local/bin/node
COPY --from=node /usr/local/include/node /usr/local/include/node
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules
# Install yarn
COPY --from=node /opt/yarn-v*/bin/* /usr/local/bin/
COPY --from=node /opt/yarn-v*/lib/* /usr/local/lib/
# Link npm and yarn
RUN ln -vs /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
    && ln -vs /usr/local/lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx


# Instal Python By Copying
COPY --from=python-build /usr/local /usr/local

ENV PATH="/usr/local/bin:${PATH}"
ENV PYTHONPATH="/usr/local/lib/python3.12/site-packages"


RUN apt-get update && \
    apt-get install -y build-essential gcc git patchelf ccache

ENV PIP_ROOT_USER_ACTION=ignore

WORKDIR /app

ENTRYPOINT ["/bin/bash", "-c", "./build.sh", "clean-build"]