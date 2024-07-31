ARG ELIXIR_VERSION=1.16.1
ARG OTP_VERSION=26.2.1
ARG UBUNTU_VERSION=20231004

ARG BUILDER_IMAGE="hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-ubuntu-jammy-${UBUNTU_VERSION}"
# ARG RUNNER_IMAGE="ubuntu-jammy:${UBUNTU_VERSION}"
# Platform is Fixed To This Because of Production Server Being In This Target Triple
FROM --platform="linux/amd64" node:lts-bookworm-slim as node
FROM --platform="linux/amd64" python:3.12.4-bookworm as python-build

FROM --platform="linux/amd64" ${BUILDER_IMAGE} as builder

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