pipeline {
    agent any

    environment {
        IMAGE_NAME = 'sethu904/react-app'  // Docker image name
        GCP_PROJECT_ID_DEV = 'development-435617'  // Development environment project ID
        GCP_PROJECT_ID_TEST = 'test-435617'  // Test environment project ID
        ARTIFACT_REGISTRY = 'us-central1-docker.pkg.dev'  // Artifact Registry location
        CLOUD_RUN_SERVICE = 'react-app-service'  // Cloud Run service name
        GCP_CREDENTIALS_ID = 'gcp-service-account'  // Jenkins credentials for GCP service account
        PATH = "/usr/local/bin:${env.PATH}"  // Ensure correct PATH for GCloud commands
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm  // Checks out code from the repository
            }
        }

        stage('Select Environment') {
            steps {
                script {
                    // Determine which environment to deploy to based on branch name
                    if (env.BRANCH_NAME == 'development') {
                        echo 'Deploying to Development Environment'
                        env.PROJECT_ID = env.GCP_PROJECT_ID_DEV
                    } else {
                        echo 'Deploying to Test Environment'
                        env.PROJECT_ID = env.GCP_PROJECT_ID_TEST
                    }
                }
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
                        gcloud config set project ${PROJECT_ID}
                        gcloud auth configure-docker ${ARTIFACT_REGISTRY}
                        docker tag ${IMAGE_NAME}:${env.BUILD_ID} ${ARTIFACT_REGISTRY}/${PROJECT_ID}/${IMAGE_NAME}:${env.BUILD_ID}
                        docker push ${ARTIFACT_REGISTRY}/${PROJECT_ID}/${IMAGE_NAME}:${env.BUILD_ID}
                        '''
                    }
                }
            }
        }

        stage('Deploy to Cloud Run') {
            steps {
                script {
                    echo "Deploying to Cloud Run..."
                    withCredentials([file(credentialsId: "${GCP_CREDENTIALS_ID}", variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
                        sh '''
                        gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS
                        gcloud config set project ${PROJECT_ID}
                        gcloud run deploy ${CLOUD_RUN_SERVICE} \
                            --image ${ARTIFACT_REGISTRY}/${PROJECT_ID}/${IMAGE_NAME}:${env.BUILD_ID} \
                            --platform managed \
                            --region us-central1 \
                            --allow-unauthenticated
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
