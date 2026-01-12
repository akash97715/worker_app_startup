from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from database import Base, engine
from auth.routes import router as auth_router
from partner.routes import router as partner_router

Base.metadata.create_all(bind=engine)

app = FastAPI(title="MetroEasy Partner Backend")

# ✅ ADD THIS BLOCK
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],   # For development ONLY
    allow_credentials=True,
    allow_methods=["*"],   # Allows OPTIONS, POST, GET, etc.
    allow_headers=["*"],
)

app.include_router(auth_router)
app.include_router(partner_router)


@app.get("/")
def health():
    return {"status": "ok"}
