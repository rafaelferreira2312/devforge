#!/bin/bash
# DevForge - Mobile Development Stack Installer
# Usage: curl -fsSL https://rafaelferreira2312.github.io/devforge/scripts/mobile/install-mobile.sh | bash

set -e

echo "🔧 DevForge: Instalando Mobile Development Stack..."

# Instalar Node.js e npm
echo "📦 Instalando Node.js..."
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

# Instalar Android SDK (Ubuntu)
echo "📦 Instalando Android SDK..."
sudo apt install -y openjdk-17-jdk android-sdk cmdliner
echo 'export ANDROID_HOME=/usr/lib/android-sdk' >> ~/.bashrc
echo 'export PATH=$PATH:$ANDROID_HOME/emulator:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools' >> ~/.bashrc
source ~/.bashrc

# Instalar React Native CLI
echo "📦 Instalando React Native CLI..."
npm install -g react-native-cli

# Instalar Expo
npm install -g expo-cli

# Instalar Flutter
echo "📦 Instalando Flutter..."
git clone https://github.com/flutter/flutter.git -b stable ~/flutter
echo 'export PATH="$PATH:$HOME/flutter/bin"' >> ~/.bashrc
source ~/.bashrc
flutter doctor

# Instalar Ionic
echo "📦 Instalando Ionic..."
npm install -g @ionic/cli

# Instalar Cordova
echo "📦 Instalando Cordova..."
npm install -g cordova

# Instalar .NET MAUI
echo "📦 Instalando .NET MAUI..."
sudo apt install -y dotnet-sdk-8.0
dotnet workload install maui

echo "✅ Mobile Stack instalada com sucesso!"