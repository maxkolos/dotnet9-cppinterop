#!/usr/bin/env bash
set -x
set -e

IMAGE_TAG="web-ui:test"

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
DOCKERFILE_PATH="$SCRIPT_DIR/../../Dockerfile"
BUILD_CONTEXT="$SCRIPT_DIR/../../"

# Build image.
docker build -t "$IMAGE_TAG" -f "$DOCKERFILE_PATH" "$BUILD_CONTEXT"
if [ $? -ne 0 ]; then
    echo "Docker build has failed"
    exit 1
fi

# Run container.
CID=$(docker run -d -p 8080:8080 "$IMAGE_TAG")
if [ $? -ne 0 ]; then
    echo "Docker run has failed"
    exit 1
fi

echo "Waiting for container..."
sleep 2

# Smoke: POST /Reverse.
RES=$(curl -s -X POST -H "Content-Type: application/json" localhost:8080/Reverse -d '{"text":"smoke"}' 2>/dev/null)
CURL_STATUS=$?
if [ $CURL_STATUS -ne 0 ]; then
    echo "Error in API call"
    docker logs "$CID"
    docker rm -f "$CID"
    exit 1
fi

echo "Response: $RES"

# Check response.
echo "$RES" | grep '"reversed":"ekoms"' >/dev/null 2>&1
GREP_STATUS=$?
if [ $GREP_STATUS -eq 0 ]; then
    echo "Smoke test succeeded"
else
    docker logs "$CID"
    docker rm -f "$CID"
    echo "Smoke test failed. See logs above"
    exit 1
fi

# Clean up.
docker rm -f "$CID"
