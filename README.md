# 🚀 CI/CD Pipeline for Dockerized Python Flask App (GitHub Actions + Docker + AWS EC2)

This project demonstrates a **complete CI/CD pipeline** for a Dockerized Python Flask application using:

- **GitHub Actions**
- **Docker & Docker Buildx**
- **Pytest**
- **Trivy**
- **Docker Hub**
- **AWS EC2**

The pipeline fully automates:

✔ Code checkout  
✔ Dependency installation  
✔ Unit testing  
✔ Docker image build  
✔ Vulnerability scanning  
✔ Push to Docker Hub  
✔ SSH deployment to EC2  

---

## 📁 Project Structure

```
cicd_docker_github/
│
├── app/
│   ├── __init__.py
│   ├── app.py
│   └── requirements.txt
│
├── tests/
│   └── test_built.py
│
├── Dockerfile
├── .dockerignore
├── .gitignore
└── .github/
    └── workflows/
        └── ci-cd.yml
```

---

## 🐍 Flask Application

```python
from flask import Flask, jsonify

app = Flask(__name__)

@app.route("/")
def hello():
    return jsonify(message="Hello from Dockerized Flask!")

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
```

---

## 🧪 Unit Tests

```python
from app.app import app

def test_home():
    client = app.test_client()
    resp = client.get("/")
    assert resp.status_code == 200
    assert resp.get_json()["message"].startswith("Hello")
```

---

## 🐳 Dockerfile

```dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY app/ app/
COPY tests/ tests/
COPY app/requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt
RUN pip install pytest

EXPOSE 5000

CMD ["python", "app/app.py"]
```

---

## 🔐 GitHub Secrets

| Secret Name | Value |
|------------|-------|
| DOCKERHUB_USERNAME | your dockerhub username |
| DOCKERHUB_TOKEN | dockerhub access token |
| SSH_PRIVATE_KEY | contents of your pem key |
| SSH_USER | ec2-user |
| SSH_HOST | EC2 public IP |

---

## 🛠️ GitHub Actions Workflow

```yaml
name: CI-CD

on:
  push:
    branches: [ main ]
  workflow_dispatch:

jobs:
  build-test-scan:
    runs-on: ubuntu-latest
    env:
      IMAGE: ${{ secrets.DOCKERHUB_USERNAME }}/my-python-app:${{ github.sha }}

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'

      - name: Install dependencies
        run: |
          pip install -r app/requirements.txt
          pip install pytest

      - name: Run unit tests
        run: |
          export PYTHONPATH="$PYTHONPATH:$(pwd)"
          pytest -q

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2

      - name: Build Docker image
        run: docker build -t $IMAGE .

      - name: Security scan using Trivy
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: ${{ env.IMAGE }}
          format: 'table'
          severity: 'HIGH,CRITICAL'
          exit-code: '1'

      - name: Login to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}

      - name: Push image to Docker Hub
        run: docker push $IMAGE

  deploy-to-ec2:
    needs: build-test-scan
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup SSH key
        uses: webfactory/ssh-agent@v0.8.0
        with:
          ssh-private-key: ${{ secrets.SSH_PRIVATE_KEY }}

      - name: Deploy to EC2
        env:
          IMAGE: ${{ secrets.DOCKERHUB_USERNAME }}/my-python-app:${{ github.sha }}
          SSH_HOST: ${{ secrets.SSH_HOST }}
          SSH_USER: ${{ secrets.SSH_USER }}

        run: |
          ssh -o StrictHostKeyChecking=no $SSH_USER@$SSH_HOST << 'EOF'
            echo "Pulling image: $IMAGE"
            docker pull $IMAGE

            echo "Stopping old container (if exists)"
            docker stop my-python-app || true
            docker rm my-python-app || true

            echo "Starting new container..."
            docker run -d --name my-python-app -p 80:5000 $IMAGE
EOF
```

---

## 🖥️ EC2 Setup

```bash
sudo yum update -y
sudo yum install -y docker
sudo systemctl start docker
sudo usermod -aG docker ec2-user
```

---

## 🌍 Access App

```
http://<EC2-PUBLIC-IP>/
```

---

## 🏆 Achievements

- Fully automated CI/CD pipeline  
- Trivy vulnerability scanning  
- Push-to-deploy automation  
- Zero-downtime deployment  
- Secure & repeatable DevOps workflow  
