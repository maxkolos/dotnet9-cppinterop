# TODO: add an alias for make and make all file paths absolute so that make can be invoked from any folder.
DOTNET_DIR=src/web-ui/
DOTNET_APP=$(DOTNET_DIR)/web-ui.csproj
SERVICE_PROJECT=src/StringService/StringService.csproj
SERVER_LOG=$(DOTNET_DIR)/server.log
SERVER_PORT=5000
BROWSER_TEST_DIR=src/tests/BrowserTests
DOTNET_INSTALL_DIR=$(HOME)/.dotnet
CPP_LIBRARY_DIR=src/CppLibrary
CPP_BUILD_DIR=$(CPP_LIBRARY_DIR)/bin
PATH := $(DOTNET_INSTALL_DIR):$(PATH)

CPP_UNIT_DIR=src/tests/CppLibraryUnittests
CPP_FUZZ_DIR=src/tests/CppLibraryFuzzer
STRING_SERVICE_DIR=src/tests/StringService.Tests
DOCKER_DIR=src/tests/DockerSmokeTest
WEBUI_TEST_DIR=src/tests/web-ui.Tests
BROWSER_TEST_DIR=src/tests/BrowserTests
DOCKER_SMOKE_TEST=src/tests/DockerSmokeTest/run_docker_smoke_test.sh
DOCKERFILE_PATH=src/Dockerfile
DOCKER_CONTEXT=src/
IMAGE_NAME=web-ui
IMAGE_TAG="web-ui:test"

.PHONY: \
	check-dotnet check-node setup \
	build-app build-service build-cpp build \
	run-server stop-server \
	test-cpp-unit test-cpp-fuzz test-string-service test-docker test-server test-browser test \
	docker-build docker-run docker-stop docker-clean

# -----------------------------
# Dependencies installation
# -----------------------------
# TODO: Add the setup to Codespace creation routine.
# TODO: Add checks of whether a dependency is already installed.
setup: install-dotnet install-node install-playwright
	@echo "Setup complete!"

install-dotnet:
	@echo "Checking .NET..."
	curl -SL https://dot.net/v1/dotnet-install.sh | bash /dev/stdin --channel 9.0 && \
	export PATH=$(DOTNET_INSTALL_DIR):$$PATH;

install-node:
	@echo "Installing Node.js + npm..."
	sudo bash -c 'curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
	apt-get install -y nodejs'

install-playwright:
	@echo "Checking Playwright..."
	cd $(BROWSER_TEST_DIR) && \
	npm ci && \
	CI=true npx playwright install --with-deps; 

# -----------------------------
# Build
# -----------------------------
build-app:
	dotnet build $(DOTNET_APP)

build-service:
	dotnet build $(SERVICE_PROJECT)

build-cpp:
	mkdir -p $(CPP_BUILD_DIR)
	cmake -S $(CPP_LIBRARY_DIR) -B $(CPP_BUILD_DIR)
	cmake --build $(CPP_BUILD_DIR) --config Release

build: build-cpp build-service build-app

# -----------------------------
# Start server
# -----------------------------
run-server:
	dotnet run --project $(DOTNET_APP)

run-server-detached:
	dotnet run --project $(DOTNET_APP) > $(SERVER_LOG) 2>&1 &
	@echo $$! > server.pid
	@echo "Waiting for server on port $(SERVER_PORT)..."
	@until curl -s http://localhost:$(SERVER_PORT)/healthz > /dev/null; do sleep 1; done

# -----------------------------
# Stop-server
# -----------------------------
stop-server-detached:
	@kill $$(cat server.pid) 2>/dev/null || true
	@rm -f server.pid

# -----------------------------
# Tests
# -----------------------------
test-cpp-unit:
	@echo "Running C++ unit tests..."
	cmake -S $(CPP_UNIT_DIR) -B $(CPP_UNIT_DIR)/bin
	cmake --build $(CPP_UNIT_DIR)/bin
	$(CPP_UNIT_DIR)/bin/test_reverse_string

test-cpp-fuzz:
	@echo "Running C++ fuzz tests..."
	@if ! command -v clang >/dev/null 2>&1; then \
		echo "clang is not found, installing..."; \
		sudo apt update; \
		sudo apt install -y clang; \
	fi
	mkdir -p $(CPP_FUZZ_DIR)/bin
	cmake -S $(CPP_FUZZ_DIR) -B $(CPP_FUZZ_DIR)/bin -DCMAKE_CXX_COMPILER=clang++
	cmake --build $(CPP_FUZZ_DIR)/bin --target fuzz_reverse_string
	$(CPP_FUZZ_DIR)/bin/fuzz_reverse_string -max_total_time=5

test-string-service:
	@echo "Running StringService tests..."
	dotnet test $(STRING_SERVICE_DIR)

test-docker:
	@echo "Running Docker smoke test via script..."
	@bash "$(DOCKER_SMOKE_TEST)"

test-server:
	@echo "Running Web-UI tests..."
	dotnet test $(WEBUI_TEST_DIR)

test-browser:
	@echo "Running Browser tests..."
	@bash -c '\
		dotnet build "$(DOTNET_APP)"; \
		echo "Starting ASP.NET app..."; \
		dotnet run --project "$(DOTNET_APP)" > "$(SERVER_LOG)" 2>&1 & \
		SERVER_PID=$$!; \
		echo "Waiting for server..."; \
		until curl -s http://localhost:$(SERVER_PORT)/healthz > /dev/null; do sleep 1; done; \
		cd "$(BROWSER_TEST_DIR)" && npm test; \
		TEST_EXIT_CODE=$$?; \
		kill $$SERVER_PID; \
		sleep 4; \
		exit $$TEST_EXIT_CODE \
	'
test-multios: test-cpp-unit test-string-service  test-server

test-linux:test-cpp-fuzz test-docker test-browser

test: test-multios test-linux
	@echo "All tests passed!"

# -----------------------------
# Overall check
# -----------------------------
build_and_test: build test

# -----------------------------
# Docker
# -----------------------------

# Build Docker image
docker-build:
	@echo "Building Docker image..."
	docker build -t $(IMAGE_TAG) -f $(DOCKERFILE_PATH) $(DOCKER_CONTEXT)

# Run Docker container in interactive mode
docker-run: docker-build
	@echo "Running Docker container..."
	docker run -it --rm -p 8080:8080 $(IMAGE_TAG)

# Run container detached (for tests)
docker-run-detached: docker-build
	@echo "Running Docker container detached..."
	docker run -d --name $(IMAGE_NAME)-tmp -p 8080:8080 $(IMAGE_TAG)

# Stop and remove container
docker-stop-detached:
	@echo "Stopping Docker container..."
	-docker rm -f $(IMAGE_NAME)-tmp

# Clean all images with this tag (optional)
docker-clean:
	@echo "Removing Docker image..."
	-docker rmi -f $(IMAGE_TAG)