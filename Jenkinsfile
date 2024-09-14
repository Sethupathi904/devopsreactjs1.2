pipeline {
    agent any

    environment {
        IMAGE_NAME = 'sethu904/react-app'
        GCP_PROJECT_ID_DEV = 'development-435617'
        GCP_PROJECT_ID_TEST = 'test-435617'
        ARTIFACT_REGISTRY = 'us-central1-docker.pkg.dev'  
        CLOUD_RUN_SERVICE = 'react-app-service'
        GCP_CREDENTIALS_ID = 'gcp-service-account'  // Jenkins credentials ID for the generic service account
        PATH = "/usr/local/bin:${env.PATH}"
    }

    stages {
        stage('Checkout') {
            steps {
                script {
                    cleanWs()
                    checkout scm
                }
            }
        }

        stage('Select Environment') {
            steps {
                script {
                    if (env.BRANCH_NAME == 'main') {
                        echo 'Deploying to Test Environment'
                        env.PROJECT_ID = env.GCP_PROJECT_ID_TEST
                        env.ARTIFACT_REGISTRY = "${ARTIFACT_REGISTRY}/test-435617/docker-repo"
                    } else {
                        echo 'Deploying to Development Environment'
                        env.PROJECT_ID = env.GCP_PROJECT_ID_DEV
                        env.ARTIFACT_REGISTRY = "${ARTIFACT_REGISTRY}/development-435617/docker-repo"
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${IMAGE_NAME}:${env.BUILD_ID}")
                }
            }
        }

        stage('Push Docker Image to Artifact Registry') {
            steps {
                script {
                    withCredentials([file(credentialsId: "${GCP_CREDENTIALS_ID}", variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
                        sh '''
                            gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS
                            gcloud config set project $PROJECT_ID
                            gcloud auth configure-docker ${ARTIFACT_REGISTRY}
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
