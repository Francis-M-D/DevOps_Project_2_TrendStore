pipeline {
    agent any

    environment {
		IMAGE = "ghostatdocker/trendstore-image"
		TAG = "${BUILD_NUMBER}"
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
                sh 'docker build -t $IMAGE:$TAG .'
            }
        }

        stage('Docker Push') {
            steps {
                // This securely injects your password from Jenkins credentials
                withCredentials([string(credentialsId: 'docker-hub-creds', variable: 'DOCKER_PASS')]) {
                    sh "echo \$DOCKER_PASS | docker login -u ghostatdocker --password-stdin"
                    sh "docker push $IMAGE:$TAG"
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                sh 'kubectl apply -f k8s/deployment.yaml'
                sh 'kubectl apply -f k8s/service.yaml'
            }
        }
	
		stage('Deploy to Kubernetes') {
			steps {
				sh '''
				kubectl set image deployment/trend-store-app \
				trendstore=ghostatdocker/trendstore-image:$TAG

				kubectl rollout status deployment/trend-store-app
				'''
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
	post {
		success {
			echo "✅ Pipeline executed successfully!"
		}
		failure {
			echo "❌ Pipeline failed. Check logs."
		}
	}
}
