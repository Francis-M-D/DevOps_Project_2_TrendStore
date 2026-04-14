Here is your **upgraded README.md** with:

✔ Screenshot placeholders (interview-ready)
✔ Environment cleanup commands
✔ Still clean and production-style

You can directly copy-paste this into your repo.

---

# 🚀 DevOps Project 2 – TrendStore CI/CD Pipeline

## 📌 Project Overview

This project demonstrates a **fully automated CI/CD pipeline on AWS** using Jenkins, Docker, Kubernetes (EKS), and Terraform.

The pipeline automates:

* GitHub integration
* Docker image build
* DockerHub image push
* Kubernetes deployment on AWS EKS
* Rolling updates via Jenkins

---

# 🧭 Architecture

```text id="arch1"
GitHub
   ↓
Jenkins (CI/CD on EC2 via Terraform)
   ↓
Docker Build
   ↓
DockerHub
   ↓
AWS EKS Cluster
   ↓
LoadBalancer (Public URL)
```

---

# 🏗️ Infrastructure

Terraform is used to provision:

* EC2 instance (Jenkins Server)
* Docker runtime setup
* Jenkins installation

📁 Location:

```text id="tf1"
infra/main.tf
```

---

# 📦 Application

This project uses a **pre-built React production build**:

```text id="app1"
Trend/dist
```

✔ No build step required
✔ Direct deployment-ready artifacts

---

# 🐳 Docker Setup

## 📄 Dockerfile

```dockerfile id="docker1"
FROM nginx:alpine

RUN rm -rf /usr/share/nginx/html/*

COPY Trend/dist/ /usr/share/nginx/html/

EXPOSE 3000

RUN sed -i 's/listen       80;/listen 3000;/' /etc/nginx/conf.d/default.conf

CMD ["nginx", "-g", "daemon off;"]
```

---

## ▶ Run Locally

```bash id="run1"
docker build -t trendstore .
docker run -p 3000:3000 trendstore
```

---

# ☸️ Kubernetes (EKS)

## 📄 Deployment

```yaml id="k8s1"
apiVersion: apps/v1
kind: Deployment
metadata:
  name: trend-store-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: trendstore
  template:
    metadata:
      labels:
        app: trendstore
    spec:
      containers:
      - name: trendstore
        image: your-dockerhub-username/trendstore-image:latest
        ports:
        - containerPort: 3000
        imagePullPolicy: Always
```

---

## 📄 Service

```yaml id="k8s2"
apiVersion: v1
kind: Service
metadata:
  name: trend-service
spec:
  type: LoadBalancer
  selector:
    app: trendstore
  ports:
    - port: 80
      targetPort: 3000
```

---

## ▶ Deploy

```bash id="deploy1"
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

---

## 🌍 Access App

```bash id="access1"
kubectl get svc
```

Use:

```text id="url1"
EXTERNAL-IP (LoadBalancer URL)
```

---

# 🔁 CI/CD Pipeline (Jenkins)

## Flow

```text id="flow1"
GitHub Push
   ↓
Jenkins Trigger
   ↓
Docker Build
   ↓
Docker Push (DockerHub)
   ↓
Kubernetes Rolling Deployment
   ↓
Live Application Update
```

---

## 📄 Jenkinsfile

```groovy id="jenkins1"
pipeline {
    agent any

    environment {
        IMAGE = "your-dockerhub-username/trendstore-image"
        TAG = "${BUILD_NUMBER}"
    }

    stages {

        stage('Checkout') {
            steps {
                git 'https://github.com/Francis-M-D/DevOps_Project_2_TrendStore.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t $IMAGE:$TAG ."
            }
        }

        stage('Docker Push') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'USER',
                    passwordVariable: 'PASS'
                )]) {
                    sh '''
                    echo $PASS | docker login -u $USER --password-stdin
                    docker push $IMAGE:$TAG
                    '''
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh '''
                kubectl set image deployment/trend-store-app \
                trendstore=$IMAGE:$TAG

                kubectl rollout status deployment/trend-store-app
                '''
            }
        }

        stage('Verify') {
            steps {
                sh '''
                kubectl get pods
                kubectl get svc
                '''
            }
        }
    }
}
```

---

# 📸 Screenshots (IMPORTANT FOR SUBMISSION)

Add these in your README:

## 🔹 Jenkins Pipeline Success

```
/screenshots/jenkins-success.png
```

## 🔹 Docker Image Push

```
/screenshots/dockerhub-image.png
```

## 🔹 Kubernetes Pods Running

```
/screenshots/k8s-pods.png
```

## 🔹 Kubernetes Service (LoadBalancer)

```
/screenshots/k8s-service.png
```

## 🔹 Live Application UI

```
/screenshots/live-app.png
```

---

# 🧹 Environment Cleanup (VERY IMPORTANT)

Use these commands to avoid AWS billing issues:

---

## 🧨 Kubernetes Cleanup

```bash id="clean1"
kubectl delete -f k8s/service.yaml
kubectl delete -f k8s/deployment.yaml
```

---

## 🧨 EKS Cluster Delete

```bash id="clean2"
eksctl delete cluster --name trend-cluster --region ap-south-1
```

---

## 🧨 Docker Cleanup (Jenkins server)

```bash id="clean3"
docker system prune -a -f
```

---

## 🧨 Terraform Cleanup (Jenkins EC2)

```bash id="clean4"
cd infra
terraform destroy
```

---

# 🧰 Tools Used

* AWS EC2 (Jenkins)
* AWS EKS
* Terraform
* Docker
* DockerHub
* Jenkins
* Kubernetes
* GitHub

---

# 🚀 Key Features

✔ Fully automated CI/CD pipeline
✔ Rolling updates (zero downtime)
✔ Dockerized frontend app
✔ Kubernetes deployment on AWS EKS
✔ Versioned Docker images
✔ Jenkins webhook automation

---

# 📁 Project Structure

```text id="structure1"
.
├── infra/
├── k8s/
├── Trend/dist/
├── Dockerfile
├── Jenkinsfile
└── README.md
```

---

# 👨‍💻 Author

**Maria Francis D**
DevOps CI/CD Project – TrendStore

---

