# Using a fully quialified version to not depend on instability in minor releases.
ARG BASE_IMAGE=9.0.302-bookworm-slim

# Build stage.
FROM mcr.microsoft.com/dotnet/sdk:${BASE_IMAGE} AS build
WORKDIR /app

# Install g++ to build C++ library.
RUN apt-get update && apt-get install -y g++ && rm -rf /var/lib/apt/lists/*

# Copy files to the container.
# TODO: Consider more selective copying (e.g. only web-ui/ and CppLibrary).
COPY . .

# Build .NET project (including C++ library) and output to /out.
# TODO: Consider separate "restore" and "publish --no-restore" to speed up deployment.
RUN dotnet publish web-ui/web-ui.csproj -c Release -o /out

# Runtime stage.
FROM mcr.microsoft.com/dotnet/aspnet:9.0-bookworm-slim AS runtime
WORKDIR /app

# Copy the published app (incl. C++ library) from build stage.
COPY --from=build /out ./

# Open a port for Web API.
EXPOSE 8080

# Launch the container.
ENTRYPOINT ["dotnet", "web-ui.dll"]