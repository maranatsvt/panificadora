# Sistema Financeiro Maranata - Configuração Final

## 🚀 Como configurar o sistema para iniciar automaticamente com o Windows

### Opção 1: Inicialização Automática (Recomendado - Mais Simples)

1. **Clique com o botão direito** no arquivo `setup_auto_start.bat`
2. **Selecione "Executar como administrador"**
3. **Aguarde** a configuração ser concluída
4. **Reinicie o computador** para testar

### Opção 2: Serviço do Windows (Alternativa - Mais Robusto)

1. **Clique com o botão direito** no arquivo `install_service_fixed.bat`
2. **Selecione "Executar como administrador"**
3. **Aguarde** a instalação do serviço
4. **Reinicie o computador** para testar

## 📋 Arquivos Importantes

### Scripts de Configuração:
- `setup_auto_start.bat` - Configura inicialização automática (método mais simples)
- `install_service_fixed.bat` - Instala serviço do Windows (método mais robusto)

### Scripts de Gerenciamento:
- `abrir_sistema.bat` - Abre o sistema no navegador
- `check_service.bat` - Verifica status do serviço
- `remove_service.bat` - Remove o serviço (se necessário)
- `start_maranata.bat` - Inicia o sistema manualmente

### Arquivos do Sistema:
- `main.py` - Aplicação principal
- `requirements.txt` - Dependências Python
- `venv/` - Ambiente virtual Python
- `maranata.db` - Banco de dados SQLite

## 🔧 Como usar o sistema

### Acesso:
- **URL:** http://localhost:8000
- **Usuário:** admin
- **Senha:** 1234

### Comandos úteis:
```cmd
# Verificar se o servidor está rodando
netstat -an | findstr :8000

# Iniciar manualmente
.\start_maranata.bat

# Abrir no navegador
.\abrir_sistema.bat

# Verificar status do serviço
.\check_service.bat
```

## 🛠️ Solução de Problemas

### Se o sistema não iniciar automaticamente:

1. **Verifique se o serviço está instalado:**
   ```cmd
   .\check_service.bat
   ```

2. **Se o serviço estiver parado, inicie manualmente:**
   ```cmd
   net start MaranataFinanceiro
   ```

3. **Se houver erro, reinstale o serviço:**
   - Execute `install_service_fixed.bat` como administrador

### Se não conseguir acessar http://localhost:8000:

1. **Verifique se o servidor está rodando:**
   ```cmd
   netstat -an | findstr :8000
   ```

2. **Se não estiver rodando, inicie manualmente:**
   ```cmd
   .\start_maranata.bat
   ```

3. **Teste com IP local:**
   - Tente acessar: http://127.0.0.1:8000

### Se precisar remover a inicialização automática:

1. **Para método de inicialização:**
   - Vá em: `%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup`
   - Delete o arquivo `Maranata_Financeiro.lnk`

2. **Para serviço do Windows:**
   - Execute `remove_service.bat` como administrador

## 📁 Estrutura do Projeto

```
Maranata/
├── main.py                    # Aplicação principal
├── requirements.txt           # Dependências Python
├── venv/                     # Ambiente virtual
├── templates/                # Templates HTML
├── static/                   # Arquivos estáticos
├── nssm-2.24/               # NSSM para serviços Windows
├── setup_auto_start.bat     # Configurar inicialização automática
├── install_service_fixed.bat # Instalar serviço Windows
├── abrir_sistema.bat        # Abrir no navegador
├── check_service.bat        # Verificar status
├── remove_service.bat       # Remover serviço
└── start_maranata.bat       # Iniciar manualmente
```

## ✅ Verificação Final

Após configurar, teste:

1. **Reinicie o computador**
2. **Aguarde 1-2 minutos** para o sistema inicializar
3. **Abra o navegador**
4. **Acesse:** http://localhost:8000
5. **Faça login** com admin/1234

Se tudo funcionar, o sistema está configurado corretamente! 🎉

## 📞 Suporte

Se encontrar problemas:
1. Verifique se executou como administrador
2. Verifique se o ambiente virtual está configurado
3. Verifique se a porta 8000 não está sendo usada
4. Execute `.\check_service.bat` para diagnosticar 