pipeline {
    agent any

    environment {
        IMAGE_NAME = 'sethu904/react-app'  // Docker image name
        GCP_PROJECT_ID_DEV = 'development-435617'  // Development environment project ID
        GCP_PROJECT_ID_TEST = 'test-435617'  // Test environment project ID
        ARTIFACT_REGISTRY_DEV = 'us-central1-docker.pkg.dev/development-435617/docker-repo'  // Development Artifact Registry URL
        ARTIFACT_REGISTRY_TEST = 'us-central1-docker.pkg.dev/test-435617/docker-repo'  // Test Artifact Registry URL
        CLOUD_RUN_SERVICE = 'react-app-service'  // Cloud Run service name
        GCP_CREDENTIALS_ID = 'gcp-service-account'  // Jenkins credentials for GCP service account
        PATH = "/usr/local/bin:${env.PATH}"  // Ensure correct PATH for GCloud commands
    }

    stages {
        stage('Checkout') {
            steps {
                script {
                    cleanWs()  // Clean workspace before checkout
                    checkout scm  // Checks out code from the repository
                }
            }
        }

        stage('Select Environment') {
            steps {
                script {
                    // Determine deployment environment based on branch name
                    if (env.BRANCH_NAME == 'test') {
                        echo 'Deploying to Test Environment'
                        env.ENVIRONMENT = 'test'
                        env.PROJECT_ID = env.GCP_PROJECT_ID_TEST
                        env.ARTIFACT_REGISTRY = env.ARTIFACT_REGISTRY_TEST
                    } else {
                        echo 'Deploying to Development Environment'
                        env.ENVIRONMENT = 'development'
                        env.PROJECT_ID = env.GCP_PROJECT_ID_DEV
                        env.ARTIFACT_REGISTRY = env.ARTIFACT_REGISTRY_DEV
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${IMAGE_NAME}:${env.BUILD_ID}")  // Build the Docker image
                }
            }
        }

        stage('Push Docker Image to Artifact Registry') {
            steps {
                script {
                    withCredentials([file(credentialsId: "${GCP_CREDENTIALS_ID}", variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
                        sh '''
                            # Authenticate with Google Cloud
                            gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS

                            # Set project
                            gcloud config set project $PROJECT_ID

                            # Configure Docker to use the Google Cloud registry
                            gcloud auth configure-docker ${ARTIFACT_REGISTRY}

                            # Tag and push the Docker image to Google Artifact Registry
                            docker tag ${IMAGE_NAME}:${BUILD_ID} ${ARTIFACT_REGISTRY}/${IMAGE_NAME}:${BUILD_ID}
                            docker push ${ARTIFACT_REGISTRY}/${IMAGE_NAME}:${BUILD_ID}
                        '''
                    }
                }
            }
        }

        stage('Deploy to Cloud Run') {
            steps {
                script {
                    withCredentials([file(credentialsId: "${GCP_CREDENTIALS_ID}", variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
                        sh '''
                            # Deploy the Docker image to Cloud Run
                            gcloud run deploy ${CLOUD_RUN_SERVICE} \
                              --image=${ARTIFACT_REGISTRY}/${IMAGE_NAME}:${BUILD_ID} \
                              --platform=managed --region=us-central1 \
                              --allow-unauthenticated --quiet
                        '''
                    }
                }
            }
        }
    }

    post {
        success {
            echo "Build and deployment succeeded!"
            emailext to: 'team@example.com',
                subject: "SUCCESS: Build ${env.BUILD_ID}",
                body: "The build and deployment of ${IMAGE_NAME} was successful."
        }
        failure {
            echo "Build or deployment failed!"
            emailext to: 'team@example.com',
                subject: "FAILURE: Build ${env.BUILD_ID}",
                body: "The build or deployment of ${IMAGE_NAME} has failed. Please check the Jenkins logs."
        }
    }
}
