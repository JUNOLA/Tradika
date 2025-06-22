import os
import re
from pathlib import Path
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from transformers import MarianMTModel, MarianTokenizer
from functools import lru_cache
import time

# Configuration
class HuggingFaceMiddleware:
    def __init__(self, app):
        self.app = app
        
    async def __call__(self, scope, receive, send):
        if scope["type"] == "http":
            # Corrige le chemin pour le reverse proxy
            if scope["path"].startswith("/proxy/"):
                scope["path"] = scope["path"][len("/proxy"):]
        await self.app(scope, receive, send)

current_dir = Path(__file__).parent

model_path = current_dir / "app" / "model"

app = FastAPI(
    title="Traducteur Bassa ↔ Français",
    description="API de traduction entre le bassa et le français",
    version="0.1.25",
)

# Configuration CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.add_middleware(HuggingFaceMiddleware)

print(f"Chargement du modèle depuis: {model_path}")
try:
    tokenizer = MarianTokenizer.from_pretrained(str(model_path))
    model = MarianMTModel.from_pretrained(str(model_path))
    print("Modèle et tokenizer chargés avec succès!")
except Exception as e:
    print(f"Erreur lors du chargement du modèle: {str(e)}")
    if os.path.exists(model_path):
        print(f"Fichiers trouvés dans {model_path}:")
        for f in os.listdir(model_path):
            print(f" - {f}")
    else:
        print(f"Le répertoire {model_path} n'existe pas!")

class TranslationRequest(BaseModel):
    text: str
    direction: str  # "fr→bs" ou "bs→fr"
    quality: str = "balanced"  # "fast", "balanced", "best"

class CorrectionRequest(BaseModel):
    original: str
    translation: str
    correction: str
    direction: str

def post_edit_translation(text, direction):
    """Correction des erreurs courantes après traduction"""
    # Liste de corrections spécifiques
    corrections = {
        "fr→bs": [
            (r'\b(\w+)\s+##', r'\1'),  # Correction des tokens mal fusionnés
            (r'@@\s+', ''),             # Suppression des marqueurs BPE
            (r'\s+([.,;!?])', r'\1'),   # Espaces avant ponctuation
            (r'(\w)\s+-\s+(\w)', r'\1-\2'),  # Correction des traits d'union
        ],
        "bs→fr": [
            (r'\b(\w+)\s+##', r'\1'),
            (r'@@\s+', ''),
            (r'(\w)\s+-\s+(\w)', r'\1-\2'),
            (r'\bje\s+vous\s+vous\b', 'je vous'),  # Correction de répétition
            (r'\btu\s+tu\b', 'tu'),                # Correction de répétition
            (r'\bils\s+ils\b', 'ils'),             # Correction de répétition
        ]
    }
    
    for pattern, replacement in corrections.get(direction, []):
        text = re.sub(pattern, replacement, text)
    
    # Capitalisation correcte
    if text and text[0].isalpha():
        text = text[0].upper() + text[1:]
    
    # Ajout de point final si manquant
    if text and text[-1] not in ['.', '!', '?']:
        text += '.'
    
    return text

# Cache pour les traductions fréquentes (texte court seulement)
@lru_cache(maxsize=1000)
def cached_translation(text, direction, quality):
    return translate_text(text, direction, quality)

def translate_text(text, direction, quality):
    """Fonction de traduction principale avec paramètres de qualité"""
    # Paramètres de qualité
    quality_settings = {
        "fast": {
            "num_beams": 1,
            "max_length": 80,
            "no_repeat_ngram_size": 1,
            "early_stopping": False
        },
        "balanced": {
            "num_beams": 4,
            "max_length": 100,
            "no_repeat_ngram_size": 2,
            "early_stopping": True
        },
        "best": {
            "num_beams": 6,
            "max_length": 120,
            "no_repeat_ngram_size": 3,
            "early_stopping": True
        }
    }
    
    # Récupération des paramètres
    params = quality_settings.get(quality, quality_settings["balanced"])
    
    # Normalisation du texte
    text = text.strip()
    
    # Ajout de marqueurs de langue pour les modèles MarianMT
    if direction == "fr→bs":
        prefix = ">>bs<< "
    else:
        prefix = ">>fr<< "
    
    text = prefix + text
    
    # Tokenization avec paramètres optimisés
    inputs = tokenizer(
        text,
        return_tensors="pt",
        padding="longest",
        truncation=True,
        max_length=params["max_length"]
    )
    
    # Génération avec paramètres améliorés
    translated = model.generate(
        **inputs,
        max_length=params["max_length"],
        num_beams=params["num_beams"],
        early_stopping=params["early_stopping"],
        no_repeat_ngram_size=params["no_repeat_ngram_size"]
    )
    
    # Décodage avec gestion des espaces
    result = tokenizer.decode(
        translated[0],
        skip_special_tokens=True,
        clean_up_tokenization_spaces=True
    )
    
    # Retirer le préfixe de langue si présent
    if result.startswith(prefix):
        result = result[len(prefix):]
    
    # Post-édition
    result = post_edit_translation(result, direction)
    
    return result

@app.get("/")
def root(request: Request):
    return {
        "message": "Bienvenue sur l'API de traduction Bassa ↔ Français",
        "health_check": f"{request.base_url}health",
        "translate_endpoint": f"{request.base_url}translate",
        "correction_endpoint": f"{request.base_url}correction"
    }

@app.get("/health")
def health_check():
    return {
        "status": "healthy", 
        "version": "0.1.25",
        "model_loaded": tokenizer is not None and model is not None
    }

@app.post("/translate")
def translate(req: TranslationRequest):
    start_time = time.time()
    
    if req.direction not in ["fr→bs", "bs→fr"]:
        return {"error": "Direction invalide. Utiliser 'fr→bs' ou 'bs→fr'."}
    
    try:
        # Utilisation du cache pour les textes courts
        if len(req.text) < 100:
            result = cached_translation(req.text, req.direction, req.quality)
        else:
            result = translate_text(req.text, req.direction, req.quality)
        
        end_time = time.time()
        duration = end_time - start_time
        
        return {
            "translation": result,
            "quality": req.quality,
            "duration": f"{duration:.2f}s"
        }
    except Exception as e:
        # Système de fallback simple
        end_time = time.time()
        duration = end_time - start_time
        
        if req.direction == "fr→bs":
            return {
                "translation": "[Erreur de traduction]",
                "quality": "fallback",
                "duration": f"{duration:.2f}s",
                "error": str(e)
            }
        else:
            return {
                "translation": "[Translation error]",
                "quality": "fallback",
                "duration": f"{duration:.2f}s",
                "error": str(e)
            }

@app.post("/correction")
def save_correction(correction: CorrectionRequest):
    """Endpoint pour enregistrer les corrections des utilisateurs"""
    try:
        # Ecriture des corrections dans un fichier log
        log_entry = f"""
        [Correction] {time.ctime()}
        Direction: {correction.direction}
        Original: {correction.original}
        Traduction: {correction.translation}
        Correction: {correction.correction}
        {'-'*50}
        """
        
        with open("corrections.log", "a", encoding="utf-8") as f:
            f.write(log_entry)
        
        return {"status": "success", "message": "Correction enregistrée"}
    except Exception as e:
        return {"status": "error", "message": str(e)}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        app, 
        host="0.0.0.0", 
        port=7860, 
        proxy_headers=True,
        forwarded_allow_ips="*"
    )