pipeline {
    agent any

    environment {
        DOCKER_CREDENTIALS_ID = 'Password@9' // Jenkins credentials ID for Docker Hub
        IMAGE_NAME = 'sethu904/react-app' // Docker image name
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm // Checks out code from the repository
            }
        }

        stage('Verify Docker') {
            steps {
                script {
                    sh 'docker --version'
                    sh 'docker info'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Build Docker image using Dockerfile in the same directory
                    def myimage = docker.build("${IMAGE_NAME}:${env.BUILD_ID}")
                    echo "Docker image built with tag ${env.BUILD_ID}"
                }
            }
        }
    }

    post {
        always {
            cleanWs() // Cleans workspace after build
        }
    }
}
