import os
from sqlalchemy import create_engine, MetaData
from sqlalchemy.orm import sessionmaker, declarative_base
import csv
import sqlite3
import sys

# Definir Base
Base = declarative_base()

# Importar modelos
from api.models import Lancamento, Boleto, Base

def backup_sqlite_to_csv():
    print("Iniciando backup do SQLite para CSV...")
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
        print(f"Exportando tabela {table} para CSV...")
        with open(f"backup/{table}.csv", 'w', newline='', encoding='utf-8') as csvfile:
            csv_writer = csv.writer(csvfile)
            cursor.execute(f"SELECT * FROM {table}")
            
            # Escrever cabeçalho
            csv_writer.writerow([i[0] for i in cursor.description])
            
            # Escrever dados
            csv_writer.writerows(cursor)
    
    conn.close()
    print("Backup concluído com sucesso!")

def restore_from_csv_to_postgres(database_url):
    print("Iniciando restauração dos dados para PostgreSQL...")
    
    # Ajuste para PostgreSQL se necessário
    if database_url.startswith("postgres://"):
        database_url = database_url.replace("postgres://", "postgresql://", 1)
    
    # Criar engine e tabelas
    engine = create_engine(database_url)
    Base.metadata.create_all(bind=engine)
    
    # Criar sessão
    SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
    session = SessionLocal()
    
    # Diretório de backup
    backup_dir = "backup"
    
    if not os.path.exists(backup_dir):
        print(f"Diretório de backup '{backup_dir}' não encontrado. Pulando restauração.")
        return
    
    # Restaurar cada arquivo CSV
    for filename in os.listdir(backup_dir):
        if filename.endswith(".csv"):
            table_name = filename[:-4]  # Remover extensão .csv
            print(f"Restaurando tabela {table_name}...")
            
            try:
                # Verificar se a tabela existe no modelo
                if table_name not in ["lancamentos", "boletos"]:
                    print(f"Tabela {table_name} não definida nos modelos. Pulando.")
                    continue
                
                with open(os.path.join(backup_dir, filename), 'r', encoding='utf-8') as csvfile:
                    csv_reader = csv.reader(csvfile)
                    headers = next(csv_reader)  # Ler cabeçalho
                    
                    # Inserir dados na tabela correspondente
                    for row in csv_reader:
                        if table_name == "lancamentos":
                            lancamento = Lancamento(
                                id=int(row[0]) if row[0] else None,
                                descricao=row[1],
                                valor=float(row[2]),
                                tipo=row[3],
                                data=row[4]
                            )
                            session.add(lancamento)
                        elif table_name == "boletos":
                            boleto = Boleto(
                                id=int(row[0]) if row[0] else None,
                                descricao=row[1],
                                valor=float(row[2]),
                                vencimento=row[3],
                                status=row[4]
                            )
                            session.add(boleto)
            except Exception as e:
                print(f"Erro ao restaurar tabela {table_name}: {str(e)}")
    
    # Commit e fechar sessão
    session.commit()
    session.close()
    print("Restauração concluída com sucesso!")

def run_migrations():
    print("Iniciando migração do banco de dados...")
    
    # Configuração do banco de dados
    DATABASE_URL = os.environ.get("DATABASE_URL", "sqlite:///./db.sqlite3")
    print(f"URL do banco de dados: {DATABASE_URL}")
    
    # Se estiver usando SQLite, fazer backup primeiro
    if DATABASE_URL.startswith("sqlite"):
        backup_sqlite_to_csv()
    
    # Ajuste para PostgreSQL se necessário
    if DATABASE_URL.startswith("postgres://"):
        DATABASE_URL = DATABASE_URL.replace("postgres://", "postgresql://", 1)
    
    # Criar engine
    engine = create_engine(DATABASE_URL)
    
    # Criar tabelas
    Base.metadata.create_all(bind=engine)
    print("Tabelas criadas com sucesso!")
    
    # Se estiver migrando para PostgreSQL, restaurar dados
    if not DATABASE_URL.startswith("sqlite"):
        restore_from_csv_to_postgres(DATABASE_URL)
    
    print("Migração concluída com sucesso!")

if __name__ == "__main__":
    # Verificar argumentos de linha de comando
    if len(sys.argv) > 1:
        if sys.argv[1] == "backup":
            backup_sqlite_to_csv()
        elif sys.argv[1] == "restore":
            database_url = os.environ.get("DATABASE_URL")
            if not database_url:
                print("Erro: Variável de ambiente DATABASE_URL não definida.")
                sys.exit(1)
            restore_from_csv_to_postgres(database_url)
        else:
            print(f"Comando desconhecido: {sys.argv[1]}")
            print("Comandos disponíveis: backup, restore")
    else:
        run_migrations()