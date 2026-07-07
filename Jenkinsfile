pipeline {
    agent any

    // Requirement: Usage of the environment block to define variables
    environment {
        APP_NAME     = 'task-tracker-app'
        APP_PORT     = '3000'
        BASE_URL     = "http://localhost:${APP_PORT}"
        IMAGE_TAG    = "latest"
    }

    stages {
        // Stage 1: SCM Pull - Checkout the code from your repository
        stage('SCM Pull') {
            steps {
                echo 'Pulling application source code from SCM repository...'
                checkout scm
            }
        }

        // Stage 2: Install Dependencies and Run Tests - Run npm install and npm test
        stage('Install Dependencies and Run Tests') {
            steps {
                echo 'Installing development dependencies...'
                sh 'npm install'
                
                echo 'Executing application test suites...'
                sh 'npm test'
            }
        }

        // Stage 3: Build - Build the multi-stage Docker image
        stage('Build') {
            steps {
                echo "Building secure multi-stage Docker image: ${APP_NAME}:${IMAGE_TAG}..."
                sh "docker build -t ${APP_NAME}:${IMAGE_TAG} ."
            }
        }

        // Stage 4: Deploy - Run the application using Docker Compose
        stage('Deploy') {
            steps {
                echo 'Launching application services via Docker Compose...'
                sh 'docker compose up -d'
                
                echo 'Giving the container a brief moment to initialize...'
                sleep 5
            }
        }

        // Stage 5: Curl - Verify the deployment by sending a curl request to the health endpoint
        stage('Curl') {
            steps {
                echo "Sending verification curl request to: ${BASE_URL}/health"
                sh "curl -s -i ${BASE_URL}/health"
                
                echo "Verifying other required assignment endpoints..."
                sh "curl -s -i ${BASE_URL}/"
                sh "curl -s -i ${BASE_URL}/api/tasks"
            }
        }

        // Stage 6: Cleanup - Tear down deployment, remove dangling images, and clean workspace
        stage('Cleanup') {
            steps {
                echo 'Tearing down active Docker Compose deployment containers...'
                sh 'docker compose down'
                
                echo 'Removing unused dangling images from host environment...'
                sh 'docker image prune -f'
                
                echo 'Wiping Jenkins workspace directory clear...'
                cleanWs()
            }
        }
    }

    post {
        always {
            echo 'Pipeline execution execution loop completed.'
        }
    }
}

