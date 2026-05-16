#!/bin/bash
# Criar projeto Flutter

PROJECT_NAME=${1:-my_flutter_app}

echo "📱 Criando projeto Flutter: $PROJECT_NAME"

# Criar projeto
flutter create "$PROJECT_NAME"

# Entrar no projeto
cd "$PROJECT_NAME"

# Executar
flutter run

echo "✅ Projeto criado! Acesse: cd $PROJECT_NAME"