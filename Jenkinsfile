pipeline {

    agent any

    environment {
        DOCKER_HUB_USER = "ctslab"
        BACKEND_IMAGE   = "${DOCKER_HUB_USER}/ems-backend"
        FRONTEND_IMAGE  = "${DOCKER_HUB_USER}/ems-frontend"
        IMAGE_TAG       = "${BUILD_NUMBER}"
        K8S_NAMESPACE   = "ems"
    }

    stages {

        // ── 1. Checkout ────────────────────────────────────────────────────
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        // ── 2. Build Docker Images ────────────────────────────────────────
            
        stage('Build Backend') {
            steps {
                dir('backend') {
                    sh "docker build -t ${BACKEND_IMAGE}:${IMAGE_TAG} -t ${BACKEND_IMAGE}:latest ."
                }
            }
        }
        stage('Build Frontend') {
            steps {
                dir('frontend') {
                    sh "docker build -t ${FRONTEND_IMAGE}:${IMAGE_TAG} -t ${FRONTEND_IMAGE}:latest ."
                }
            }
        }


        // ── 3. Verify Images ───────────────────────────────────────────────
        stage('Verify Docker Images') {
            steps {
                sh "docker image inspect ${BACKEND_IMAGE}:${IMAGE_TAG}"
                sh "docker image inspect ${FRONTEND_IMAGE}:${IMAGE_TAG}"
            }
        }

        // ── 4. Docker Login ────────────────────────────────────────────────
        stage('Docker Login') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockercreds',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASS'
                    )
                ]) 
                {
                    sh "echo \"${DOCKER_PASS}\" | docker login -u ${DOCKER_USER} --password-stdin"
                }
            }
        }

        // ── 5. Push Images ─────────────────────────────────────────────────
        stage('Docker Push') {
            parallel {
                stage('Push Backend') {
                    steps {
                        sh "docker push ${BACKEND_IMAGE}:${IMAGE_TAG}"
                        sh "docker push ${BACKEND_IMAGE}:latest"
                    }
                }
                stage('Push Frontend') {
                    steps {
                        sh "docker push ${FRONTEND_IMAGE}:${IMAGE_TAG}"
                        sh "docker push ${FRONTEND_IMAGE}:latest"
                    }
                }
            }
        }

        // ── 6. Verify Push ─────────────────────────────────────────────────
        stage('Verify Docker Hub Push') {
            steps {
                sh "docker pull ${BACKEND_IMAGE}:${IMAGE_TAG}"
                sh "docker pull ${FRONTEND_IMAGE}:${IMAGE_TAG}"
            }
        }

    }

    post {

        success {
            echo 'Pipeline Executed Successfully — EMS deployed to Kubernetes!'
        }

        failure {
            echo 'Pipeline Failed — check stage logs above for details.'
        }

        unstable {
            echo 'Pipeline Unstable'
        }

        aborted {
            echo 'Pipeline Aborted'
        }

        // Always clean up dangling images to avoid disk bloat on the agent
        always {
            sh "docker image prune -f"
        }

    }

}
