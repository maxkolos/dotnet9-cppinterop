#!/usr/bin/env bash
set -x

cd CppLibraryTests && sh run_unittests.sh && sh run_fuzz_tests.sh && cd .. && \
cd StringService.Tests && sh run_StringServiceTests.sh && cd .. && \
# Note: Docker test rarely flakes when running with many other tests.
cd DockerSmokeTest && sh run_docker_smoke_test.sh && cd .. && \
cd web-ui.Tests && sh run_tests.sh && cd .. && \
cd BrowserTests && sh run_browser_tests.sh && cd .. && echo "All tests passed"