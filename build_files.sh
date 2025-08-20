#!/bin/bash

# Remover arquivos desnecessários
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

# Limpar diretórios de upload e relatórios
rm -rf uploads/*
rm -rf reports/*

# Criar diretórios necessários
mkdir -p uploads
mkdir -p reports

# Otimizar imagens (se houver)
find . -type f -name "*.jpg" -exec jpegoptim --strip-all {} \;
find . -type f -name "*.png" -exec optipng -o7 {} \;

# Criar arquivo .vercelignore
cat > .vercelignore << EOL
.git
.gitignore
.env
.env.*
__pycache__
*.pyc
*.pyo
*.pyd
.Python
env/
venv/
.venv/
.idea/
.vscode/
tests/
docs/
*.log
.DS_Store
Thumbs.db
EOL 