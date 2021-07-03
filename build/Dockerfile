# Stage 1: Use image builder to build the target binaries
# Copyright Contributors to the Open Cluster Management project

FROM golang:1.16 AS builder

ARG COMPONENT
WORKDIR /workspace/${COMPONENT}
COPY go.mod go.mod
COPY go.sum go.sum

RUN go mod download

COPY Makefile Makefile
COPY cmd/ cmd/
COPY pkg/ pkg/
COPY version/ version/
RUN make build

# Stage 2: Copy the binaries from the image builder to the base image
FROM registry.access.redhat.com/ubi8/ubi-minimal:latest
ARG COMPONENT
ENV USER_UID=1001
ENV USER_NAME=${COMPONENT}

# install operator binary
COPY --from=builder /workspace/${COMPONENT}/bin/${COMPONENT} /usr/local/bin/${COMPONENT}

COPY build/scripts/user_setup /usr/local/scripts/user_setup
RUN  /usr/local/scripts/user_setup

COPY  build/scripts/entrypoint /usr/local/bin/entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint"]

RUN microdnf update && \
    microdnf clean all

USER ${USER_UID}
