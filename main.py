from fastapi import FastAPI, Request, Form, status, HTTPException
from fastapi.responses import HTMLResponse, RedirectResponse, StreamingResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
from sqlalchemy import create_engine, Column, Integer, String, Float, DateTime, Date
from sqlalchemy.orm import sessionmaker, declarative_base
from datetime import datetime, date
from starlette.middleware.sessions import SessionMiddleware
import csv
from io import StringIO
import os

# Configuração do banco local
DATABASE_URL = os.getenv("DATABASE_URL", "sqlite:///maranata.db")
engine = create_engine(DATABASE_URL, connect_args={"check_same_thread": False})
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# Modelos
class Lancamento(Base):
    __tablename__ = "lancamentos"
    id = Column(Integer, primary_key=True, index=True)
    descricao = Column(String, nullable=False)
    valor = Column(Float, nullable=False)
    tipo = Column(String, nullable=False)  # ENTRADA ou SAIDA
    data = Column(DateTime, default=datetime.now)

class Boleto(Base):
    __tablename__ = "boletos"
    id = Column(Integer, primary_key=True, index=True)
    descricao = Column(String, nullable=False)
    valor = Column(Float, nullable=False)
    vencimento = Column(Date, nullable=False)
    status = Column(String, nullable=False, default="PENDENTE")  # PENDENTE ou PAGO

# Criar tabelas
Base.metadata.create_all(bind=engine)

# App FastAPI
app = FastAPI()
app.add_middleware(SessionMiddleware, secret_key="maranata-secret-key")

# Static e templates
app.mount("/static", StaticFiles(directory="static"), name="static")
templates = Jinja2Templates(directory="templates")

# Usuário fixo
USUARIO = os.getenv("USUARIO", "admin")
SENHA = os.getenv("SENHA", "1234")

# Tela de login (principal)
@app.get("/", response_class=HTMLResponse)
def login_get(request: Request):
    if request.session.get("logado"):
        return RedirectResponse("/dashboard", status_code=303)
    return templates.TemplateResponse("login.html", {"request": request, "erro": None})

@app.post("/login", response_class=HTMLResponse)
def login_post(request: Request, usuario: str = Form(...), senha: str = Form(...)):
    if usuario == USUARIO and senha == SENHA:
        request.session["logado"] = True
        return RedirectResponse("/dashboard", status_code=303)
    return templates.TemplateResponse("login.html", {"request": request, "erro": "Usuário ou senha inválidos."})

@app.get("/logout")
def logout(request: Request):
    request.session.clear()
    return RedirectResponse("/", status_code=303)

# Dashboard protegido
@app.get("/dashboard", response_class=HTMLResponse)
def dashboard(request: Request):
    if not request.session.get("logado"):
        return RedirectResponse("/", status_code=303)
    
    db = SessionLocal()
    
    # Buscar lançamentos (entradas e saídas)
    lancamentos = db.query(Lancamento).all()
    total_entradas = sum(l.valor for l in lancamentos if l.tipo == "ENTRADA")
    total_saidas = sum(l.valor for l in lancamentos if l.tipo == "SAIDA")
    saldo = total_entradas - total_saidas
    
    # Buscar boletos para a lista
    boletos = db.query(Boleto).order_by(Boleto.vencimento.asc()).all()
    
    db.close()
    return templates.TemplateResponse("index.html", {
        "request": request,
        "boletos": boletos,
        "total_entradas": total_entradas,
        "total_saidas": total_saidas,
        "saldo": saldo,
        "hoje": date.today()
    })

# Adicionar lançamento (protegido)
@app.post("/adicionar")
def adicionar(request: Request, descricao: str = Form(...), valor: float = Form(...), tipo: str = Form(...)):
    if not request.session.get("logado"):
        return RedirectResponse("/", status_code=303)
    
    db = SessionLocal()
    novo = Lancamento(descricao=descricao, valor=valor, tipo=tipo)
    db.add(novo)
    db.commit()
    db.close()
    return RedirectResponse("/dashboard", status_code=status.HTTP_303_SEE_OTHER)

# Editar lançamento (protegido)
@app.post("/editar/{id}")
def editar(request: Request, id: int, descricao: str = Form(...), valor: float = Form(...), tipo: str = Form(...)):
    if not request.session.get("logado"):
        return RedirectResponse("/", status_code=303)
    
    db = SessionLocal()
    lanc = db.query(Lancamento).filter(Lancamento.id == id).first()
    if not lanc:
        db.close()
        raise HTTPException(status_code=404, detail="Lançamento não encontrado")
    lanc.descricao = descricao
    lanc.valor = valor
    lanc.tipo = tipo
    db.commit()
    db.close()
    return RedirectResponse("/dashboard", status_code=status.HTTP_303_SEE_OTHER)

# Excluir lançamento (protegido)
@app.post("/excluir/{id}")
def excluir(request: Request, id: int):
    if not request.session.get("logado"):
        return RedirectResponse("/", status_code=303)
    
    db = SessionLocal()
    lanc = db.query(Lancamento).filter(Lancamento.id == id).first()
    if lanc:
        db.delete(lanc)
        db.commit()
    db.close()
    return RedirectResponse("/dashboard", status_code=status.HTTP_303_SEE_OTHER)

def parse_date(date_str):
    try:
        return datetime.strptime(date_str, '%Y-%m-%d')
    except:
        return None

@app.get("/relatorio", response_class=HTMLResponse)
def relatorio(request: Request, data_inicio: str = '', data_fim: str = ''):
    if not request.session.get("logado"):
        return RedirectResponse("/", status_code=303)
    
    db = SessionLocal()
    query = db.query(Lancamento)
    di = parse_date(data_inicio) if data_inicio else None
    df = parse_date(data_fim) if data_fim else None
    if di:
        query = query.filter(Lancamento.data >= di)
    if df:
        query = query.filter(Lancamento.data <= df)
    lancamentos = query.order_by(Lancamento.data.desc()).all()
    total_entradas = sum(l.valor for l in lancamentos if l.tipo == "ENTRADA")
    total_saidas = sum(l.valor for l in lancamentos if l.tipo == "SAIDA")
    saldo = total_entradas - total_saidas
    db.close()
    
    return templates.TemplateResponse("relatorio.html", {
        "request": request,
        "lancamentos": lancamentos,
        "total_entradas": total_entradas,
        "total_saidas": total_saidas,
        "saldo": saldo,
        "data_inicio": data_inicio,
        "data_fim": data_fim
    })

@app.get("/exportar_csv", name="exportar_csv")
def exportar_csv(request: Request, data_inicio: str = '', data_fim: str = ''):
    if not request.session.get("logado"):
        return RedirectResponse("/", status_code=303)
    
    db = SessionLocal()
    query = db.query(Lancamento)
    di = parse_date(data_inicio) if data_inicio else None
    df = parse_date(data_fim) if data_fim else None
    if di:
        query = query.filter(Lancamento.data >= di)
    if df:
        query = query.filter(Lancamento.data <= df)
    lancamentos = query.order_by(Lancamento.data.desc()).all()
    db.close()
    
    output = StringIO()
    writer = csv.writer(output)
    writer.writerow(["Data", "Descrição", "Valor", "Tipo"])
    for l in lancamentos:
        writer.writerow([
            l.data.strftime('%d/%m/%Y %H:%M'),
            l.descricao,
            f"{l.valor:.2f}",
            l.tipo
        ])
    output.seek(0)
    return StreamingResponse(output, media_type="text/csv", headers={"Content-Disposition": "attachment; filename=relatorio.csv"})

@app.get("/boletos", response_class=HTMLResponse)
def boletos(request: Request):
    if not request.session.get("logado"):
        return RedirectResponse("/", status_code=303)
    
    db = SessionLocal()
    boletos = db.query(Boleto).order_by(Boleto.vencimento.asc()).all()
    db.close()
    
    return templates.TemplateResponse("boletos.html", {
        "request": request,
        "boletos": boletos
    })

@app.post("/adicionar_boleto")
def adicionar_boleto(request: Request, descricao: str = Form(...), valor: float = Form(...), vencimento: str = Form(...), status: str = Form(...)):
    if not request.session.get("logado"):
        return RedirectResponse("/", status_code=303)
    
    db = SessionLocal()
    boleto = Boleto(
        descricao=descricao,
        valor=valor,
        vencimento=datetime.strptime(vencimento, "%Y-%m-%d").date(),
        status=status
    )
    db.add(boleto)
    db.commit()
    db.close()
    return RedirectResponse("/boletos", status_code=303)

@app.post("/editar_boleto/{id}")
def editar_boleto(request: Request, id: int, descricao: str = Form(...), valor: float = Form(...), vencimento: str = Form(...), status: str = Form(...)):
    if not request.session.get("logado"):
        return RedirectResponse("/", status_code=303)
    
    db = SessionLocal()
    boleto = db.query(Boleto).filter(Boleto.id == id).first()
    if boleto:
        boleto.descricao = descricao
        boleto.valor = valor
        boleto.vencimento = datetime.strptime(vencimento, "%Y-%m-%d").date()
        boleto.status = status
        db.commit()
    db.close()
    return RedirectResponse("/boletos", status_code=303)

@app.post("/excluir_boleto/{id}")
def excluir_boleto(request: Request, id: int):
    if not request.session.get("logado"):
        return RedirectResponse("/", status_code=303)
    
    db = SessionLocal()
    boleto = db.query(Boleto).filter(Boleto.id == id).first()
    if boleto:
        db.delete(boleto)
        db.commit()
    db.close()
    return RedirectResponse("/boletos", status_code=303)

@app.get("/entradas", response_class=HTMLResponse)
def entradas(request: Request):
    if not request.session.get("logado"):
        return RedirectResponse("/", status_code=303)
    
    db = SessionLocal()
    lancamentos = db.query(Lancamento).order_by(Lancamento.data.desc()).all()
    db.close()
    
    return templates.TemplateResponse("entradas.html", {
        "request": request,
        "lancamentos": lancamentos
    })

@app.get("/exportar_relatorio_pdf")
def exportar_relatorio_pdf(request: Request, data_inicio: str = '', data_fim: str = ''):
    if not request.session.get("logado"):
        return RedirectResponse("/", status_code=303)
    
    db = SessionLocal()
    query = db.query(Lancamento)
    di = parse_date(data_inicio) if data_inicio else None
    df = parse_date(data_fim) if data_fim else None
    if di:
        query = query.filter(Lancamento.data >= di)
    if df:
        query = query.filter(Lancamento.data <= df)
    lancamentos = query.order_by(Lancamento.data.desc()).all()
    total_entradas = sum(l.valor for l in lancamentos if l.tipo == "ENTRADA")
    total_saidas = sum(l.valor for l in lancamentos if l.tipo == "SAIDA")
    saldo = total_entradas - total_saidas
    db.close()

    # Retornar uma resposta simples por enquanto
    return HTMLResponse(content="<h1>Relatório PDF</h1><p>Funcionalidade em desenvolvimento</p>")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)