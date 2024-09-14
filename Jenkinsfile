pipeline {
    agent any

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
    }

    post {
        always {
            script {
                echo "Cleaning up workspace..."
            }
            cleanWs() // Cleans workspace after build
        }
    }
}
