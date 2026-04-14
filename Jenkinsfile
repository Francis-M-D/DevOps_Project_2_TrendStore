pipeline {
    agent any

    environment {
        IMAGE = "ghostatdocker/trendstore-image"
    }

    stages {

		stage('Git Checkout') {
			steps {
				// Change 'main' to whatever your branch is named (e.g., 'master' or 'develop')
				git branch: 'main', url: 'https://github.com/Francis-M-D/DevOps_Project_2_TrendStore.git'
			}
		}

        stage('Docker Build') {
            steps {
                sh 'docker build -t $IMAGE .'
            }
        }

        stage('Docker Push') {
            steps {
                // This securely injects your password from Jenkins credentials
                withCredentials([string(credentialsId: 'docker-hub-creds', variable: 'DOCKER_PASS')]) {
                    sh "echo \$DOCKER_PASS | docker login -u ghostatdocker --password-stdin"
                    sh "docker push $IMAGE"
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                sh 'kubectl apply -f k8s/deployment.yaml'
                sh 'kubectl apply -f k8s/service.yaml'
            }
        }
		stage('Verify Deployment') {
            steps {
                sh '''
                kubectl get pods
                kubectl get svc
                '''
            }
        }
		}		
	}
	
    post {
        success {
            echo "✅ Pipeline executed successfully!"
        }
        failure {
            echo "❌ Pipeline failed. Check logs."
        }
    }
	
}
