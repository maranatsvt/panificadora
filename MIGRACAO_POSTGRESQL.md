# Guia de Migração para PostgreSQL no Vercel

## Por que migrar para PostgreSQL?

O SQLite não é recomendado para uso em produção no Vercel devido à natureza efêmera do sistema de arquivos. O PostgreSQL é uma alternativa robusta e adequada para ambientes de produção.

## Passo a Passo para Migração

### 1. Criar um banco de dados PostgreSQL

Existem várias opções para hospedar seu banco de dados PostgreSQL:

#### Opção 1: Neon (Recomendado para Vercel)

1. Acesse [Neon](https://neon.tech/) e crie uma conta gratuita
2. Crie um novo projeto
3. Selecione a região mais próxima do seu público-alvo
4. Após a criação, você receberá uma string de conexão no formato:
   ```
   postgresql://user:password@endpoint/database
   ```

#### Opção 2: Supabase

1. Acesse [Supabase](https://supabase.com/) e crie uma conta gratuita
2. Crie um novo projeto
3. Vá para Configurações > Database para obter sua string de conexão

#### Opção 3: Railway

1. Acesse [Railway](https://railway.app/) e crie uma conta
2. Crie um novo projeto com PostgreSQL
3. Obtenha a string de conexão nas configurações do projeto

#### Opção 4: ElephantSQL

1. Acesse [ElephantSQL](https://www.elephantsql.com/) e crie uma conta
2. Crie uma nova instância (o plano gratuito oferece 20MB)
3. Obtenha a string de conexão nas configurações da instância

### 2. Instalar dependências necessárias

Adicione as seguintes dependências ao seu arquivo `requirements.txt`:

```
psycopg2-binary==2.9.9
alembic==1.12.0
```

### 3. Modificar a configuração do banco de dados

Atualize o arquivo `api/vercel_app.py` para usar PostgreSQL em vez de SQLite:

```python
import os
from sqlalchemy import create_engine, Column, Integer, String, Float, DateTime, Date
from sqlalchemy.orm import sessionmaker, declarative_base

# Configuração do banco para PostgreSQL
DATABASE_URL = os.environ.get("DATABASE_URL", "sqlite:///./db.sqlite3")

# Ajuste para PostgreSQL se necessário (necessário para alguns provedores como Heroku)
if DATABASE_URL.startswith("postgres://"):
    DATABASE_URL = DATABASE_URL.replace("postgres://", "postgresql://", 1)

# Configuração do engine
engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# Resto do código permanece o mesmo...
```

### 4. Criar script de migração

Crie um arquivo `migrations.py` na raiz do projeto:

```python
import os
from sqlalchemy import create_engine, MetaData
from alembic import command
from alembic.config import Config
from api.vercel_app import Base, Lancamento, Boleto

def run_migrations():
    # Configuração do banco de dados
    DATABASE_URL = os.environ.get("DATABASE_URL", "sqlite:///./db.sqlite3")
    
    # Ajuste para PostgreSQL se necessário
    if DATABASE_URL.startswith("postgres://"):
        DATABASE_URL = DATABASE_URL.replace("postgres://", "postgresql://", 1)
    
    # Criar engine
    engine = create_engine(DATABASE_URL)
    
    # Criar tabelas
    Base.metadata.create_all(bind=engine)
    
    print("Migração concluída com sucesso!")

if __name__ == "__main__":
    run_migrations()
```

### 5. Configurar variáveis de ambiente no Vercel

1. Acesse o dashboard do Vercel
2. Selecione seu projeto
3. Vá para "Settings" > "Environment Variables"
4. Adicione a variável `DATABASE_URL` com o valor da string de conexão do PostgreSQL

### 6. Executar a migração

Você pode executar a migração de duas formas:

#### Opção 1: Localmente antes do deploy

```bash
# Instale as dependências
pip install -r requirements.txt

# Execute o script de migração
python migrations.py
```

#### Opção 2: Durante o deploy no Vercel

Atualize o arquivo `vercel-build.sh` para incluir a execução da migração:

```bash
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

# Executar migração do banco de dados
echo "Executando migração do banco de dados..."
python migrations.py

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
```

### 7. Considerações adicionais

#### Tipos de dados

Alguns tipos de dados podem precisar de ajustes ao migrar de SQLite para PostgreSQL:

- SQLite não tem tipos de data/hora estritos como PostgreSQL
- SQLite é mais permissivo com tipos de dados

#### Backup de dados

Antes de migrar, faça um backup dos seus dados SQLite:

```python
import sqlite3
import csv
import os

def backup_sqlite_to_csv():
    # Conectar ao banco SQLite
    conn = sqlite3.connect("db.sqlite3")
    cursor = conn.cursor()
    
    # Obter lista de tabelas
    cursor.execute("SELECT name FROM sqlite_master WHERE type='table';")
    tables = cursor.fetchall()
    
    # Criar diretório de backup se não existir
    if not os.path.exists("backup"):
        os.makedirs("backup")
    
    # Exportar cada tabela para CSV
    for table_name in tables:
        table = table_name[0]
        with open(f"backup/{table}.csv", 'w', newline='') as csvfile:
            csv_writer = csv.writer(csvfile)
            cursor.execute(f"SELECT * FROM {table}")
            
            # Escrever cabeçalho
            csv_writer.writerow([i[0] for i in cursor.description])
            
            # Escrever dados
            csv_writer.writerows(cursor)
    
    conn.close()
    print("Backup concluído com sucesso!")

if __name__ == "__main__":
    backup_sqlite_to_csv()
```

#### Restauração de dados

Para restaurar os dados no PostgreSQL:

```python
import psycopg2
import csv
import os

def restore_from_csv_to_postgres(database_url):
    # Conectar ao PostgreSQL
    conn = psycopg2.connect(database_url)
    cursor = conn.cursor()
    
    # Diretório de backup
    backup_dir = "backup"
    
    # Restaurar cada arquivo CSV
    for filename in os.listdir(backup_dir):
        if filename.endswith(".csv"):
            table_name = filename[:-4]  # Remover extensão .csv
            with open(os.path.join(backup_dir, filename), 'r') as csvfile:
                csv_reader = csv.reader(csvfile)
                headers = next(csv_reader)  # Ler cabeçalho
                
                for row in csv_reader:
                    # Construir query de inserção
                    placeholders = ",".join(["%s"] * len(row))
                    columns = ",".join(headers)
                    query = f"INSERT INTO {table_name} ({columns}) VALUES ({placeholders})"
                    
                    # Executar query
                    cursor.execute(query, row)
    
    # Commit e fechar conexão
    conn.commit()
    conn.close()
    print("Restauração concluída com sucesso!")

if __name__ == "__main__":
    database_url = os.environ.get("DATABASE_URL")
    restore_from_csv_to_postgres(database_url)
```

## Conclusão

Migrar para PostgreSQL é uma etapa importante para garantir a estabilidade e escalabilidade do seu aplicativo no Vercel. Embora exija algumas modificações no código e configuração adicional, os benefícios em termos de confiabilidade e desempenho compensam o esforço.

Lembre-se de testar a migração em um ambiente de desenvolvimento antes de aplicar em produção.