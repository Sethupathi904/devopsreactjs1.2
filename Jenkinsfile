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

                            # Configure Docker to use the Google Cloud registry
                            gcloud auth configure-docker ${ARTIFACT_REGISTRY}

                            # Tag and push the Docker image to Google Artifact Registry
                            docker tag ${IMAGE_NAME}:${BUILD_ID} ${ARTIFACT_REGISTRY}/${PROJECT_ID}/${IMAGE_NAME}:${BUILD_ID}
                            docker push ${ARTIFACT_REGISTRY}/${PROJECT_ID}/${IMAGE_NAME}:${BUILD_ID}
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
                              --image=${ARTIFACT_REGISTRY}/${PROJECT_ID}/${IMAGE_NAME}:${BUILD_ID} \
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
