#!/bin/bash
# DevForge - .NET Uninstaller

DOTNET_VERSION=${1:-8.0}
echo "⚠️ Removendo .NET SDK $DOTNET_VERSION..."

sudo apt remove -y dotnet-sdk-${DOTNET_VERSION} || brew uninstall --cask dotnet-sdk
sudo apt autoremove -y

echo "🗑️ .NET SDK $DOTNET_VERSION removido."