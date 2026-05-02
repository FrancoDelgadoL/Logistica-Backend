from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

# Esto deja entrar las peticiones del Frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], # El "*" permite que cualquier frontend se conecte (ideal para desarrollo local)
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def inicio():
    return {"mensaje": "Backend de Logística conectado con éxito"}