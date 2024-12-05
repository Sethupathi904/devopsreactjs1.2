pipeline {
    agent any
    
    environment {
        DOCKER_CREDENTIALS_ID = 'Password@9' // Jenkins credentials ID for Docker Hub
        IMAGE_NAME = 'sethu904/react-app' // Docker image name
        PROJECT_ID = 'groovy-legacy-434014-d0' // Google Cloud project ID
        GCR_REGISTRY = 'gcr.io' // Google Container Registry URL
    }

    stages {
        stage('Checkout') {
            steps {
                script {
                    echo "Checking out code..."
                    checkout scm // Checks out code from the repository
                }
            }
        }
        stage('Verify Docker') {
            steps {
                script {
                    echo "Verifying Docker installation..."
                    def dockerVersion = sh(script: 'docker --version', returnStdout: true).trim()
                    echo "Docker Version: ${dockerVersion}"
                }
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    echo "Building Docker image..."
                    def myimage = docker.build("${IMAGE_NAME}:${env.BUILD_ID}")
                    echo "Docker image built with tag ${env.BUILD_ID}"
                }
            }
        }
        stage('Push to Google Artifact Registry') {
            steps {
                script {
                    echo "Authenticating with Google Cloud..."
                    
                    // Authenticate with Google Cloud (ensure you have the Google Cloud SDK installed on Jenkins agent)
                    withCredentials([file(credentialsId: 'google-cloud-key', variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
                        sh 'gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS'
                        sh 'gcloud config set project ${PROJECT_ID}'
                    }
                    
                    echo "Tagging Docker image..."
                    def imageTag = "${GCR_REGISTRY}/${PROJECT_ID}/${IMAGE_NAME}:${env.BUILD_ID}"
                    sh "docker tag ${IMAGE_NAME}:${env.BUILD_ID} ${imageTag}"
                    
                    echo "Pushing Docker image to Google Artifact Registry..."
                    sh "docker push ${imageTag}"
                }
            }
        }
    }

    post {
        always {
            script {
                echo "Cleaning up workspace..."
                cleanWs() // Clean up workspace
            }
        }
    }
}
