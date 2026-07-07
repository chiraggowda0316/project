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

        // Optimized Stage: Uses Docker to run tests, eliminating the local host "npm: command not found" issue
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

        stage('Deploy') {
            steps {
                echo 'Launching application services via Docker Compose...'
                sh 'docker compose up -d'
                sleep 5
            }
        }

        stage('Curl') {
            steps {
                echo "Sending verification curl request to: ${BASE_URL}/health"
                sh "curl -s -i ${BASE_URL}/health"
                
                echo "Verifying other required assignment endpoints..."
                sh "curl -s -i ${BASE_URL}/"
                sh "curl -s -i ${BASE_URL}/api/tasks"
            }
        }

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

