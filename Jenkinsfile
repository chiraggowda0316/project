pipeline {
    agent any

    environment {
        APP_NAME     = 'task-tracker-app'
        CONTAINER_NAME = 'task_tracker_container'
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

        // Updated Stage: Uses direct docker run to avoid docker-compose missing tool path issues
        stage('Deploy') {
            steps {
                echo 'Launching application service container...'
                // Removes old container instance if left over from prior failed runs
                sh "docker rm -f ${CONTAINER_NAME} || true"
                sh "docker run -d --name ${CONTAINER_NAME} -p ${APP_PORT}:${APP_PORT} -e NODE_ENV=production ${APP_NAME}:${IMAGE_TAG}"
                
                echo 'Allowing service initialization sync runtime buffer...'
                sleep 7
            }
        }

        stage('Curl') {
            steps {
                echo "Sending verification curl requests to assignment targets..."
                
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
        echo 'Skipping container teardown to allow live verification...'
        // sh "docker rm -f ${CONTAINER_NAME} || true" <--- Comment this out!
        sh 'docker image prune -f'
        cleanWs()
    }
}

    post {
        always {
            echo 'Pipeline execution run finalized.'
        }
    }
}

