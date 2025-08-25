#!/usr/bin/env bash
set -x

cd CppLibraryUnittests && sh run_unittests.sh && cd .. && \
cd CppLibraryFuzzer && sh run_fuzz_tests.sh && cd .. && \
cd StringService.Tests && sh run_StringServiceTests.sh && cd .. && \
cd DockerSmokeTest && sh run_docker_smoke_test.sh && cd .. && \
cd web-ui.Tests && sh run_tests.sh && cd .. && \
cd BrowserTests && sh run_browser_tests.sh && cd .. && echo "All tests passed"