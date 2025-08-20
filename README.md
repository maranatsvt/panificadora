# Sistema Financeiro Maranata

Sistema completo de controle financeiro com dashboard, relatórios, boletos e exportação de dados.

## 🚀 Instalação Automática (Windows)

### 1. Pré-requisitos
- **Python 3.8 ou superior** instalado
- Download: https://www.python.org/downloads/

### 2. Instalação
1. Baixe todos os arquivos do projeto
2. Extraia em uma pasta (ex: `C:\Maranata`)
3. Execute `install.bat` (duplo clique)
4. Aguarde a instalação das dependências

### 3. Execução
1. Execute `start.bat` (duplo clique)
2. Abra o navegador em: http://localhost:8000
3. Login: `admin` / Senha: `1234`

## 📋 Funcionalidades

### ✅ Dashboard
- Visão geral das finanças
- Total de entradas e saídas
- Saldo atual
- Gráfico de movimentação

### ✅ Lançamentos
- Adicionar entradas e saídas
- Editar lançamentos
- Excluir registros
- Histórico completo

### ✅ Boletos
- Cadastro de boletos
- Controle de vencimentos
- Status (Pendente/Pago)
- Edição e exclusão

### ✅ Relatórios
- Filtros por data
- Exportação CSV
- Relatório PDF (em desenvolvimento)
- Totais e saldos

### ✅ Segurança
- Sistema de login
- Sessões protegidas
- Dados persistentes

## 🗄️ Banco de Dados

- **SQLite local** (`maranata.db`)
- Dados persistentes (não perdem ao desligar)
- Backup automático do arquivo

## 🔧 Configuração

### Alterar credenciais
Edite o arquivo `main.py`:
```python
USUARIO = "seu_usuario"
SENHA = "sua_senha"
```

### Porta do servidor
Edite o arquivo `main.py`:
```python
uvicorn.run(app, host="0.0.0.0", port=8000)
```

## 📁 Estrutura do Projeto

```
maranata/
├── main.py              # Aplicação principal
├── requirements.txt     # Dependências
├── install.bat         # Instalador automático
├── start.bat           # Iniciador do servidor
├── maranata.db         # Banco de dados (criado automaticamente)
├── static/             # Arquivos estáticos (CSS, JS, imagens)
└── templates/          # Templates HTML
    ├── login.html
    ├── index.html
    ├── entradas.html
    ├── boletos.html
    └── relatorio.html
```

## 🛠️ Comandos Manuais

### Instalar dependências
```bash
pip install -r requirements.txt
```

### Executar servidor
```bash
python main.py
```

### Acessar aplicação
- URL: http://localhost:8000
- Usuário: admin
- Senha: 1234

## 🔒 Segurança

- **Dados locais:** Todos os dados ficam no computador
- **Sem internet:** Funciona offline
- **Backup:** Faça backup do arquivo `maranata.db`

## 📞 Suporte

Para problemas ou dúvidas:
1. Verifique se o Python está instalado
2. Execute `install.bat` novamente
3. Verifique se a porta 8000 está livre

## 🔄 Atualizações

Para atualizar o sistema:
1. Faça backup do arquivo `maranata.db`
2. Substitua os arquivos do projeto
3. Execute `install.bat` novamente
4. Restaure o backup do banco

---

**Sistema Financeiro Maranata** - Controle completo das suas finanças! 