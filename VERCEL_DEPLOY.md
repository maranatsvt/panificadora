# Deploy no Vercel

Este documento contém instruções para realizar o deploy do sistema Maranata na plataforma Vercel.

## Pré-requisitos

- Conta na Vercel (https://vercel.com)
- Git instalado na máquina local
- Repositório do projeto no GitHub, GitLab ou Bitbucket

## Passos para Deploy

### 1. Preparação do Projeto

O projeto já está configurado para deploy na Vercel com os seguintes arquivos:

- `vercel.json`: Configuração principal para o deploy
- `requirements.txt`: Dependências do projeto
- `runtime.txt`: Versão do Python
- `api/index.py`: Ponto de entrada da aplicação

### 2. Deploy via Vercel Dashboard

1. Faça login na sua conta Vercel
2. Clique em "New Project"
3. Importe o repositório do projeto
4. Configure as variáveis de ambiente (veja o arquivo .env.example)
5. Clique em "Deploy"

### 3. Variáveis de Ambiente

Configure as seguintes variáveis de ambiente no dashboard da Vercel:

- `DATABASE_URL`: URL de conexão com o banco de dados
- `USUARIO`: Nome de usuário para acesso ao sistema
- `SENHA`: Senha para acesso ao sistema
- `APP_SECRET`: Chave secreta para sessões

### 4. Limitações

- O sistema usa SQLite por padrão, que funciona apenas em modo leitura no ambiente Vercel
- Para persistência de dados, considere usar um banco de dados externo como PostgreSQL ou MySQL

### 5. Comandos Úteis

```bash
# Deploy manual via CLI da Vercel
vercel

# Deploy para produção
vercel --prod
```

## Suporte

Em caso de problemas com o deploy, verifique:

1. Logs de build e deploy na dashboard da Vercel
2. Configuração correta das variáveis de ambiente
3. Compatibilidade das dependências no arquivo requirements.txt