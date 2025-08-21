set -e
set -x

# .NET 9
curl -sSL https://dot.net/v1/dotnet-install.sh | bash /dev/stdin --channel 9.0 && export PATH=$HOME/.dotnet:$PATH && dotnet --version

# Browser tests
echo "Updating apt..."
sudo apt update

echo "Installing Node.js + npm..."
sudo apt install -y nodejs npm

echo "Installing npm dependencies + Playwright (with browsers & system deps)..."
cd src/tests/BrowserTests
npm install
npx playwright install --with-deps
cd ../../..
