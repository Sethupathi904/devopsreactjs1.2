pipeline {
    agent any

    stages {
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
