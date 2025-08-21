#!/bin/bash

# Script de build específico para o Vercel
echo "Iniciando build para o Vercel..."

# Garantir que os diretórios estáticos existam
echo "Verificando diretórios estáticos..."
if [ ! -d "static" ]; then
  echo "Diretório static não encontrado, criando..."
  mkdir -p static
fi

if [ ! -d "templates" ]; then
  echo "Diretório templates não encontrado, criando..."
  mkdir -p templates
fi

# Copiar arquivos estáticos para o diretório correto
echo "Copiando arquivos estáticos..."
cp -r static/* ./static/ 2>/dev/null || echo "Nenhum arquivo estático para copiar"

# Copiar templates para o diretório correto
echo "Copiando templates..."
cp -r templates/* ./templates/ 2>/dev/null || echo "Nenhum template para copiar"

# Remover arquivos desnecessários
echo "Limpando arquivos desnecessários..."
find . -type d -name "__pycache__" -exec rm -r {} +
find . -type f -name "*.pyc" -delete
find . -type f -name "*.pyo" -delete
find . -type f -name "*.pyd" -delete
find . -type f -name ".DS_Store" -delete
find . -type f -name "Thumbs.db" -delete

# Remover diretórios de desenvolvimento
rm -rf venv/
rm -rf .venv/
rm -rf env/
rm -rf .env/
rm -rf .idea/
rm -rf .vscode/
rm -rf tests/
rm -rf docs/

echo "Build concluído com sucesso!"