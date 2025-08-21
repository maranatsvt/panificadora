# Solução para o Erro 404 no Deploy do Vercel

Este documento contém instruções para resolver o erro 404 (NOT_FOUND) que ocorre durante o deploy do sistema Maranata na plataforma Vercel.

## Problema

O erro 404 (NOT_FOUND) ocorre porque o Vercel não consegue encontrar os arquivos estáticos e templates da aplicação devido à forma como os caminhos são referenciados no código.

```
404: NOT_FOUND
Code: NOT_FOUND
ID: gru1::t5zwn-1755731078980-5189b5940a85
```

## Soluções Implementadas

### 1. Caminhos Absolutos para Arquivos Estáticos e Templates

Modificamos o arquivo `api/index.py` para usar caminhos absolutos baseados no diretório raiz do projeto:

```python
# Static e templates - usando caminhos absolutos para o ambiente Vercel
import pathlib
base_dir = pathlib.Path(__file__).parent.parent
app.mount("/static", StaticFiles(directory=str(base_dir / "static")), name="static")
templates = Jinja2Templates(directory=str(base_dir / "templates"))
```

### 2. Configuração do Vercel.json

Atualizamos o arquivo `vercel.json` para incluir um handler de sistema de arquivos, que ajuda o Vercel a servir arquivos estáticos corretamente:

```json
"routes": [
  {
    "src": "/static/(.*)",
    "dest": "/static/$1"
  },
  {
    "handle": "filesystem"
  },
  {
    "src": "/(.*)",
    "dest": "/api/index.py"
  }
]
```

## Passos Adicionais para o Deploy

### 1. Verificar Variáveis de Ambiente

Certifique-se de que todas as variáveis de ambiente necessárias estão configuradas no dashboard da Vercel:

- `DATABASE_URL`: URL de conexão com o banco de dados
- `USUARIO`: Nome de usuário para acesso ao sistema
- `SENHA`: Senha para acesso ao sistema
- `APP_SECRET`: Chave secreta para sessões

### 2. Redeploy do Projeto

Após fazer as alterações acima, faça um novo deploy do projeto:

1. Commit das alterações no repositório Git
2. Push para o repositório remoto
3. O Vercel detectará automaticamente as alterações e fará um novo deploy

Alternativamente, você pode forçar um novo deploy através do dashboard da Vercel.

### 3. Verificar Logs

Se o erro persistir, verifique os logs de build e runtime no dashboard da Vercel para identificar possíveis problemas adicionais.

## Considerações sobre o Banco de Dados

Lembre-se que o SQLite funciona apenas em modo leitura no ambiente Vercel. Para persistência de dados, considere usar um banco de dados externo como PostgreSQL ou MySQL, configurando a variável de ambiente `DATABASE_URL` adequadamente.