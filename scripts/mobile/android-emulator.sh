#!/bin/bash
# Criar emulador Android via CLI

echo "🔧 Criando emulador Android..."

# Listar disponíveis
avdmanager list

# Criar emulador
avdmanager create avd -n Pixel_4_API_33 -k "system-images;android-33;google_apis;x86_64"

# Iniciar emulador
emulator -avd Pixel_4_API_33