#!/usr/bin/env bash
set -x
set -e

APP_PATH="../../web-ui/web-ui.csproj"

echo "Building ASP.NET app..."
dotnet build "$APP_PATH"

echo "Starting ASP.NET app..."
dotnet run --project "$APP_PATH" > server.log 2>&1 &
SERVER_PID=$!

echo "Waiting for server to start..."
# TODO: Prefer to limit the number of atempts.
until curl -s http://localhost:5000/healthz > /dev/null; do
  sleep 1
done

echo "Running Playwright E2E tests..."
npm test
TEST_EXIT_CODE=$?

echo "Stopping ASP.NET app..."
kill $SERVER_PID
# TODO: Wait until the server stops instead of fixed timeout.
sleep 4

exit $TEST_EXIT_CODE
