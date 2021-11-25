#!/usr/bin/env bash

rimraf \
    node_modules \
    .serverless \
    canary \
    infra/cleanup-function.zip \
    infra/cleanup-function/cfnresponse \
    infra/cleanup-function/cfnresponse-1.1.2.dist-info \
    infra/cleanup-function/urllib3 \
    infra/cleanup-function/urllib3-1.26.7.dist-info

yarn cache clean
