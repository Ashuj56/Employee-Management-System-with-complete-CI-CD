pipeline {

    agent any

    environment {
        DOCKER_HUB_USER = "ctslab"
        BACKEND_IMAGE = "${DOCKER_HUB_USER}/ems-backend"
        FRONTEND_IMAGE = "${DOCKER_HUB_USER}/ems-frontend"
        IMAGE_TAG = "${BUILD_NUMBER}"

        GITOPS_REPO = "https://github.com/Ashuj56/Employee-Management-System-Using-GitOps-ArgoCD.git"
        GITOPS_BRANCH = "main"
        GITOPS_CREDENTIALS = "github-gitops"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Backend') {
            steps {
                dir('backend') {
                    sh """
                        docker build \
                        -t ${BACKEND_IMAGE}:${IMAGE_TAG} \
                        -t ${BACKEND_IMAGE}:latest .
                    """
                }
            }
        }

        stage('Build Frontend') {
            steps {
                dir('frontend') {
                    sh """
                        docker build \
                        -t ${FRONTEND_IMAGE}:${IMAGE_TAG} \
                        -t ${FRONTEND_IMAGE}:latest .
                    """
                }
            }
        }

        stage('Verify Docker Images') {
            steps {
                sh """
                    docker image inspect ${BACKEND_IMAGE}:${IMAGE_TAG}
                    docker image inspect ${FRONTEND_IMAGE}:${IMAGE_TAG}
                """
            }
        }

        stage('Docker Login') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockercreds',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASS'
                    )
                ]) {
                    sh '''
                        echo "$DOCKER_PASS" | docker login \
                        -u "$DOCKER_USER" \
                        --password-stdin
                    '''
                }
            }
        }

        stage('Docker Push') {
            parallel {

                stage('Push Backend') {
                    steps {
                        sh """
                            docker push ${BACKEND_IMAGE}:${IMAGE_TAG}
                            docker push ${BACKEND_IMAGE}:latest
                        """
                    }
                }

                stage('Push Frontend') {
                    steps {
                        sh """
                            docker push ${FRONTEND_IMAGE}:${IMAGE_TAG}
                            docker push ${FRONTEND_IMAGE}:latest
                        """
                    }
                }
            }
        }

        stage('Verify Docker Hub Push') {
            steps {
                sh """
                    docker pull ${BACKEND_IMAGE}:${IMAGE_TAG}
                    docker pull ${FRONTEND_IMAGE}:${IMAGE_TAG}
                """
            }
        }

        stage('Update GitOps Repository') {
            steps {

                dir('gitops') {

                    deleteDir()

                    git(
                        url: "${GITOPS_REPO}",
                        branch: "${GITOPS_BRANCH}",
                        credentialsId: "${GITOPS_CREDENTIALS}"
                    )

                    withCredentials([
                        gitUsernamePassword(
                            credentialsId: "${GITOPS_CREDENTIALS}",
                            gitToolName: 'Default'
                        )
                    ]) {

                        sh """
                            sed -i "s|image: ${BACKEND_IMAGE}:.*|image: ${BACKEND_IMAGE}:${IMAGE_TAG}|" k8s/backend-deployment.yaml

                            sed -i "s|image: ${FRONTEND_IMAGE}:.*|image: ${FRONTEND_IMAGE}:${IMAGE_TAG}|" k8s/frontend-deployment.yaml

                            git config user.name "Jenkins"
                            git config user.email "jenkins@localhost"

                            git add k8s/backend-deployment.yaml k8s/frontend-deployment.yaml

                            git commit -m "Update EMS images to build ${IMAGE_TAG}"

                            git push origin ${GITOPS_BRANCH}
                        """
                    }
                }
            }
        }
    }

    post {

        success {
            echo "EMS CI + GitOps pipeline completed successfully"
        }

        failure {
            echo "EMS pipeline failed"
        }

        always {
            sh "docker image prune -f"
        }
    }
}