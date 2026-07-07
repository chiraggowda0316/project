pipeline {
    agent any

    environment {
        APP_NAME     = 'task-tracker-app'
        APP_PORT     = '3000'
        BASE_URL     = "http://localhost:${APP_PORT}"
        IMAGE_TAG    = "latest"
    }

    stages {
        stage('SCM Pull') {
            steps {
                echo 'Pulling application source code from SCM repository...'
                checkout scm
            }
        }

        stage('Install Dependencies and Run Tests') {
            steps {
                echo 'Running tests inside a containerized Node.js environment...'
                sh 'docker run --rm -v "$(pwd)":/usr/src/app -w /usr/src/app node:20-alpine sh -c "npm install && npm test"'
            }
        }

        stage('Build') {
            steps {
                echo "Building secure multi-stage Docker image: ${APP_NAME}:${IMAGE_TAG}..."
                sh "docker build -t ${APP_NAME}:${IMAGE_TAG} ."
            }
        }

        // Updated Stage: Uses the hyphenated legacy binary to match your EC2 engine's setup
        stage('Deploy') {
            steps {
                echo 'Launching application services via legacy Docker Compose engine...'
                sh 'docker-compose up -d'
                
                echo 'Allowing service initialization sync runtime buffer...'
                sleep 7
            }
        }

        stage('Curl') {
            steps {
                echo "Sending verification curl request to assignment targets..."
                
                echo "--- Endpoint 1: Root Dashboard Page ---"
                sh "curl -s -i ${BASE_URL}/"
                
                echo "--- Endpoint 2: Health Object Summary Status ---"
                sh "curl -s -i ${BASE_URL}/health"
                
                echo "--- Endpoint 3: Tasks Collection Payload Arrays ---"
                sh "curl -s -i ${BASE_URL}/api/tasks"
            }
        }

        stage('Cleanup') {
            steps {
                echo 'Tearing down active Docker Compose deployment containers...'
                sh 'docker-compose down'
                
                echo 'Removing unused dangling images from host environment...'
                sh 'docker image prune -f'
                
                echo 'Wiping Jenkins workspace directory clear...'
                cleanWs()
            }
        }
    }

    post {
        always {
            echo 'Pipeline execution run finalized.'
        }
    }
}

