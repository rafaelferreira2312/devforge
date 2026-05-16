#!/bin/bash
# Criar projeto React Native

PROJECT_NAME=${1:-MyReactNativeApp}

echo "📱 Criando projeto React Native: $PROJECT_NAME"

# Inicializar
npx react-native init "$PROJECT_NAME"

# Entrar no projeto
cd "$PROJECT_NAME"

# Executar no Android
npx react-native run-android

echo "✅ Projeto criado! Acesse: cd $PROJECT_NAME"