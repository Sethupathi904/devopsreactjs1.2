pipeline {
    agent any

    environment {
        DOCKER_CREDENTIALS_ID = 'Password@9' // Jenkins credentials ID for Docker Hub
        IMAGE_NAME = 'sethu904/react-app' // Docker image name
        PROJECT_ID = 'groovy-legacy-434014-d0'
        CLUSTER_NAME = 'k8s-cluster'
        LOCATION = 'us-central1-c'
        CREDENTIALS_ID = 'kubernetes'    
        PATH = "/usr/local/bin:${env.PATH}"    
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
                    try {
                        sh 'docker --version'
                        sh 'docker info'
                    } catch (Exception e) {
                        error "Docker is not properly installed or configured. Exiting."
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    try {
                        myimage = docker.build("${IMAGE_NAME}:${env.BUILD_ID}")
                    } catch (Exception e) {
                        error "Failed to build Docker image. Exiting."
                    }
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    try {
                        echo "Push Docker Image"
                        withCredentials([string(credentialsId: 'dockerhub', variable: 'dockerhub')]) {
                            sh "docker login -u sethu904 -p ${dockerhub}"
                        }
                        myimage.push("${env.BUILD_ID}")
                    } catch (Exception e) {
                        error "Failed to push Docker image to DockerHub. Exiting."
                    } finally {
                        // Clean up local Docker image to free up space
                        sh "docker rmi ${IMAGE_NAME}:${env.BUILD_ID}"
                    }
                }
            }
        }

        stage('Deploy to K8s') {
            steps {
                script {
                    try {
                        echo "Deployment started ..."
                        sh 'ls -ltr'
                        sh 'pwd'
                        sh "sed -i 's/tagversion/${env.BUILD_ID}/g' serviceLB.yaml"
                        sh "sed -i 's/tagversion/${env.BUILD_ID}/g' deployment.yaml"

                        // Deploy to GKE
                        echo "Start deployment of serviceLB.yaml"
                        step([$class: 'KubernetesEngineBuilder', projectId: env.PROJECT_ID, clusterName: env.CLUSTER_NAME, location: env.LOCATION, manifestPattern: 'serviceLB.yaml', credentialsId: env.CREDENTIALS_ID, verifyDeployments: true])
                        
                        echo "Start deployment of deployment.yaml"
                        step([$class: 'KubernetesEngineBuilder', projectId: env.PROJECT_ID, clusterName: env.CLUSTER_NAME, location: env.LOCATION, manifestPattern: 'deployment.yaml', credentialsId: env.CREDENTIALS_ID, verifyDeployments: true])

                        // Verify deployment
                        sh "kubectl rollout status deployment/your-deployment-name"
                    } catch (Exception e) {
                        error "Kubernetes deployment failed. Exiting."
                    }
                }
            }
        }
    }

    post {
        always {
            cleanWs() // Cleans workspace after build
        }
        success {
            echo "Build and deployment succeeded!"
            // Email notification
            emailext to: 'team@example.com',
                subject: "SUCCESS: Build ${env.BUILD_ID}",
                body: "The build and deployment of ${IMAGE_NAME} was successful."
        }
        failure {
            echo "Build or deployment failed!"
            // Email notification
            emailext to: 'team@example.com',
                subject: "FAILURE: Build ${env.BUILD_ID}",
                body: "The build or deployment of ${IMAGE_NAME} has failed. Please check the Jenkins logs."

            // Optional Slack notification (assuming Slack plugin is set up)
            slackSend(channel: '#devops-alerts', color: 'danger', message: "Build or deployment failed for ${IMAGE_NAME}:${env.BUILD_ID}.")
        }
    }
}
