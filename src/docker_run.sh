#!/usr/bin/env bash
set -x
docker build -t web-ui . && docker run -it --rm -p 8080:8080 web-ui