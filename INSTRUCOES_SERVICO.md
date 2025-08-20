# Configuração do Serviço Automático - Sistema Maranata

## Como configurar o sistema para iniciar automaticamente com o Windows

### Opção 1: Usando Serviço do Windows (Recomendado)

1. **Execute como Administrador:**
   - Clique com o botão direito no arquivo `start_service.bat`
   - Selecione "Executar como administrador"

2. **O script irá:**
   - Verificar se você tem permissões de administrador
   - Instalar o serviço "MaranataFinanceiro"
   - Configurar para iniciar automaticamente com o Windows
   - Iniciar o serviço imediatamente

3. **Após a instalação:**
   - O sistema estará disponível em: http://localhost:8000
   - Usuário: admin
   - Senha: 1234

### Comandos úteis para gerenciar o serviço:

```cmd
# Verificar status do serviço
check_service.bat

# Iniciar o serviço manualmente
net start MaranataFinanceiro

# Parar o serviço
net stop MaranataFinanceiro

# Reiniciar o serviço
net stop MaranataFinanceiro && net start MaranataFinanceiro

# Remover o serviço (se necessário)
remove_service.bat
```

### Opção 2: Usando Inicialização do Windows (Alternativa)

Se preferir não usar serviço, pode usar o método de inicialização:

1. Execute `auto_start.bat` como administrador
2. O sistema será adicionado à pasta de inicialização do Windows

### Verificação

Para verificar se está funcionando:

1. Reinicie o computador
2. Abra o navegador
3. Acesse: http://localhost:8000
4. Faça login com admin/1234

### Solução de Problemas

**Se o serviço não iniciar:**
1. Execute `check_service.bat` para ver o status
2. Verifique os logs do Windows (Visualizador de Eventos)
3. Tente reiniciar o serviço: `net stop MaranataFinanceiro && net start MaranataFinanceiro`

**Se precisar remover o serviço:**
1. Execute `remove_service.bat` como administrador

**Se o NSSM não for encontrado:**
1. Verifique se o arquivo `nssm-2.24.zip` foi extraído corretamente
2. O arquivo `nssm.exe` deve estar em `nssm-2.24\win64\`

### Notas Importantes

- O serviço usa o ambiente virtual (`venv`) criado anteriormente
- O banco de dados SQLite será criado automaticamente
- O sistema roda na porta 8000
- Certifique-se de que a porta 8000 não está sendo usada por outro programa 

## **PASSO 1: Verifique o ambiente virtual**

Abra o terminal na pasta do projeto e execute:

```sh
dir venv\Scripts\python.exe
```
Se aparecer "Arquivo não encontrado", crie o ambiente virtual:
```sh
python -m venv venv
```
Depois, instale as dependências:
```sh
venv\Scripts\activate
pip install -r requirements.txt
``` 