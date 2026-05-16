#!/bin/bash
# DevForge - Setup Python Virtual Environment for IA/ML

VENV_NAME=${1:-ia-env}
PYTHON_VERSION=${2:-3.11}

echo "🔧 Criando ambiente virtual: $VENV_NAME com Python $PYTHON_VERSION..."

python${PYTHON_VERSION} -m venv ~/$VENV_NAME
source ~/$VENV_NAME/bin/activate

pip install --upgrade pip
pip install numpy pandas matplotlib jupyter ipykernel

python -m ipykernel install --user --name=$VENV_NAME --display-name="Python ($VENV_NAME)"

echo "✅ Ambiente criado! Ative com: source ~/$VENV_NAME/bin/activate"