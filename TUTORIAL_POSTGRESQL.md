# Tutorial Passo a Passo: Configuração do PostgreSQL para o Projeto Maranata

Este tutorial irá guiá-lo através do processo completo de configuração de um banco de dados PostgreSQL para o projeto Maranata, incluindo a criação do banco de dados, configuração do ambiente e migração dos dados existentes.

## 1. Criação do Banco de Dados PostgreSQL

Escolha um dos seguintes provedores para hospedar seu banco de dados PostgreSQL:

### Opção 1: Neon (Recomendado para Vercel)

1. Acesse [Neon](https://neon.tech/) e crie uma conta gratuita
2. Clique em "New Project" para criar um novo projeto
3. Dê um nome ao seu projeto (ex: "maranata-db")
4. Selecione a região mais próxima do seu público-alvo (ex: "São Paulo" ou "US East")
5. Clique em "Create Project"
6. Após a criação, você será redirecionado para o dashboard do projeto
7. No menu lateral, clique em "Connection Details"
8. Copie a string de conexão no formato `postgresql://user:password@endpoint/database`

### Opção 2: Supabase

1. Acesse [Supabase](https://supabase.com/) e crie uma conta gratuita
2. Clique em "New Project" para criar um novo projeto
3. Dê um nome ao seu projeto e defina uma senha segura para o banco de dados
4. Selecione a região mais próxima do seu público-alvo
5. Clique em "Create New Project"
6. Após a criação, vá para "Settings" > "Database" no menu lateral
7. Role para baixo até encontrar "Connection String" e selecione "URI"
8. Copie a string de conexão e substitua `[YOUR-PASSWORD]` pela senha que você definiu

### Opção 3: Railway

1. Acesse [Railway](https://railway.app/) e crie uma conta
2. Clique em "New Project" e selecione "Provision PostgreSQL"
3. Após a criação, clique no banco de dados PostgreSQL no dashboard
4. Vá para a aba "Connect" e copie a string de conexão em "Postgres Connection URL"

### Opção 4: ElephantSQL

1. Acesse [ElephantSQL](https://www.elephantsql.com/) e crie uma conta gratuita
2. Clique em "Create New Instance"
3. Dê um nome à sua instância e selecione o plano gratuito "Tiny Turtle" (20MB)
4. Selecione a região mais próxima do seu público-alvo
5. Clique em "Review" e depois em "Create Instance"
6. Após a criação, clique na instância criada no dashboard
7. Copie a string de conexão em "URL"

## 2. Configuração do Ambiente Local

### Instalar Dependências

1. Abra o terminal no diretório raiz do projeto
2. Execute o seguinte comando para instalar as dependências necessárias:

```bash
pip install psycopg2-binary alembic
```

3. Verifique se as dependências já estão no arquivo `requirements.txt`. Se não estiverem, adicione-as:

```
psycopg2-binary==2.9.9
alembic==1.12.0
```

### Configurar Variável de Ambiente

1. Crie um arquivo `.env` na raiz do projeto (se ainda não existir)
2. Adicione a string de conexão do PostgreSQL ao arquivo:

```
DATABASE_URL=sua_string_de_conexao_postgresql
```

3. Para testar localmente, você pode carregar as variáveis de ambiente usando:

```bash
# No Windows
set DATABASE_URL=sua_string_de_conexao_postgresql

# No Linux/Mac
export DATABASE_URL=sua_string_de_conexao_postgresql
```

## 3. Migração do Banco de Dados

### Backup dos Dados Existentes

1. Certifique-se de que o banco de dados SQLite atual está atualizado
2. Execute o script de backup para exportar os dados para CSV:

```bash
python migrations.py backup
```

Isso criará uma pasta `backup` com arquivos CSV contendo os dados de cada tabela.

### Criação das Tabelas no PostgreSQL

1. Com a variável de ambiente `DATABASE_URL` configurada, execute o script de migração:

```bash
python migrations.py
```

Este comando irá:
- Fazer backup dos dados do SQLite (se estiver usando SQLite)
- Criar as tabelas no PostgreSQL
- Restaurar os dados do backup para o PostgreSQL

## 4. Configuração no Vercel

### Adicionar Variável de Ambiente no Vercel

1. Acesse o [Dashboard do Vercel](https://vercel.com/dashboard)
2. Selecione seu projeto
3. Vá para "Settings" > "Environment Variables"
4. Adicione uma nova variável:
   - Nome: `DATABASE_URL`
   - Valor: sua string de conexão PostgreSQL
5. Clique em "Save"

### Atualizar Configuração de Build

O arquivo `vercel-build.sh` já está configurado para executar a migração durante o deploy. Certifique-se de que ele está atualizado com o seguinte conteúdo:

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

## 5. Verificação e Testes

### Testar Localmente

1. Configure a variável de ambiente `DATABASE_URL` localmente
2. Execute o aplicativo:

```bash
python main.py
```

3. Verifique se o aplicativo está conectando corretamente ao PostgreSQL
4. Teste as funcionalidades principais para garantir que tudo está funcionando

### Verificar Logs no Vercel

Após o deploy no Vercel:

1. Acesse o dashboard do Vercel
2. Selecione seu projeto
3. Vá para a aba "Deployments" e clique no deploy mais recente
4. Clique em "Functions Logs" para verificar os logs da aplicação
5. Procure por mensagens relacionadas à conexão com o banco de dados

## 6. Solução de Problemas Comuns

### Erro de Conexão

Se você encontrar erros de conexão:

1. Verifique se a string de conexão está correta
2. Confirme se o IP do Vercel está na lista de permissões do seu provedor de banco de dados
3. Verifique se as credenciais estão corretas

### Erro de Migração

Se a migração falhar:

1. Verifique os logs para identificar o problema específico
2. Execute a migração manualmente no ambiente local para depurar
3. Verifique se há incompatibilidades de tipos de dados entre SQLite e PostgreSQL

### Problemas com Tipos de Dados

Alguns tipos de dados podem precisar de ajustes ao migrar de SQLite para PostgreSQL:

- SQLite é mais permissivo com tipos de dados
- PostgreSQL é mais rigoroso com tipos de data/hora
- Verifique se os tipos de dados nos modelos são compatíveis com PostgreSQL

## 7. Considerações Finais

### Backup Regular

Configure backups regulares do seu banco de dados PostgreSQL:

1. A maioria dos provedores oferece backups automáticos
2. Considere implementar um script de backup personalizado para maior segurança

### Monitoramento

Monitore o desempenho do seu banco de dados:

1. Verifique o uso de recursos no dashboard do seu provedor
2. Configure alertas para uso elevado de recursos ou erros frequentes

### Escalabilidade

À medida que seu aplicativo cresce:

1. Considere atualizar para um plano com mais recursos
2. Implemente índices para consultas frequentes
3. Otimize consultas que estão consumindo muitos recursos

---

Parabéns! Seu aplicativo Maranata agora está configurado para usar PostgreSQL no Vercel, proporcionando maior confiabilidade e escalabilidade para seu ambiente de produção.