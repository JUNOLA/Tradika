FROM python:3.10

WORKDIR /code

# Install system dependencies
RUN apt-get update && apt-get install -y git curl

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install sacremoses

COPY . .

# Vérification de la structure des fichiers
RUN echo "Structure des fichiers:" && ls -lR /code/app/model

EXPOSE 7860

# Utilisez directement le fichier server.py comme point d'entrée
CMD ["uvicorn", "server:app", "--host", "0.0.0.0", "--port", "7860", "--proxy-headers", "--forwarded-allow-ips", "*"]