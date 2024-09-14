pipeline {
    agent any

    environment {
        IMAGE_NAME = 'us-central1-docker.pkg.dev/development-435617/docker-repo/react-app'  // Docker image name
        ARTIFACT_REGISTRY = 'us-central1-docker.pkg.dev'  // Artifact Registry location
        GCP_PROJECT_ID = 'development-435617'  // Your GCP project ID
        GCP_CREDENTIALS_ID = 'gcp-service-account'  // Jenkins credentials for GCP service account
        PATH = "/usr/local/bin:${env.PATH}"  // Ensure correct PATH for GCloud commands
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm  // Checks out code from the repository
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
                    echo "Building Docker Image"
                    myimage = docker.build("${IMAGE_NAME}:${env.BUILD_ID}")
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    echo "Push Docker Image to Google Artifact Registry"
                    withCredentials([file(credentialsId: "${GCP_CREDENTIALS_ID}", variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
                        sh '''
                        gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS
                        gcloud config set project ${GCP_PROJECT_ID}
                        gcloud auth configure-docker ${ARTIFACT_REGISTRY}
                        docker tag ${IMAGE_NAME}:${env.BUILD_ID} ${ARTIFACT_REGISTRY}/${GCP_PROJECT_ID}/${IMAGE_NAME}:${env.BUILD_ID}
                        docker push ${ARTIFACT_REGISTRY}/${GCP_PROJECT_ID}/${IMAGE_NAME}:${env.BUILD_ID}
                        '''
                    }
                }
            }
        }
    }

    post {
        always {
            cleanWs()  // Cleans workspace after build
        }
    }
}
