pipeline {

    agent any

    environment {
        DOCKER_HUB_USER = "ctslab"

        BACKEND_IMAGE  = "${DOCKER_HUB_USER}/ems-backend"
        FRONTEND_IMAGE = "${DOCKER_HUB_USER}/ems-frontend"

        IMAGE_TAG = "${BUILD_NUMBER}"

        GITOPS_REPO = "https://github.com/Ashuj56/Employee-Management-System-Using-GitOps-ArgoCD.git"
        GITOPS_BRANCH = "main"

        GITOPS_CREDENTIALS = "github-gitops"
    }

    stages {

        // ============================================================
        // 1. CHECKOUT APPLICATION REPOSITORY
        // ============================================================

        stage('Checkout') {
            steps {
                checkout scm
            }
        }


        // ============================================================
        // 2. BUILD BACKEND DOCKER IMAGE
        // ============================================================

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


        // ============================================================
        // 3. BUILD FRONTEND DOCKER IMAGE
        // ============================================================

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


        // ============================================================
        // 4. VERIFY LOCAL DOCKER IMAGES
        // ============================================================

        stage('Verify Docker Images') {
            steps {
                sh """
                    docker image inspect ${BACKEND_IMAGE}:${IMAGE_TAG}
                    docker image inspect ${FRONTEND_IMAGE}:${IMAGE_TAG}
                """
            }
        }


        // ============================================================
        // 5. DOCKER HUB LOGIN
        // ============================================================

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
                        echo "$DOCKER_PASS" | \
                        docker login \
                        -u "$DOCKER_USER" \
                        --password-stdin
                    '''
                }
            }
        }


        // ============================================================
        // 6. PUSH DOCKER IMAGES
        // ============================================================

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


        // ============================================================
        // 7. VERIFY DOCKER HUB PUSH
        // ============================================================

        stage('Verify Docker Hub Push') {
            steps {

                sh """
                    docker pull ${BACKEND_IMAGE}:${IMAGE_TAG}
                    docker pull ${FRONTEND_IMAGE}:${IMAGE_TAG}
                """
            }
        }


        // ============================================================
        // 8. UPDATE GITOPS REPOSITORY
        // ============================================================

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
                            echo "======================================"
                            echo "Updating GitOps repository"
                            echo "Build Number: ${IMAGE_TAG}"
                            echo "======================================"

                            echo ""
                            echo "Current backend image:"
                            grep "image:" k8s/backend-deployment.yaml

                            echo ""
                            echo "Current frontend image:"
                            grep "image:" k8s/frontend-deployment.yaml


                            # Update backend image
                            sed -i \
                                "s|image: ${BACKEND_IMAGE}:.*|image: ${BACKEND_IMAGE}:${IMAGE_TAG}|" \
                                k8s/backend-deployment.yaml


                            # Update frontend image
                            sed -i \
                                "s|image: ${FRONTEND_IMAGE}:.*|image: ${FRONTEND_IMAGE}:${IMAGE_TAG}|" \
                                k8s/frontend-deployment.yaml


                            echo ""
                            echo "Updated backend image:"
                            grep "image:" k8s/backend-deployment.yaml

                            echo ""
                            echo "Updated frontend image:"
                            grep "image:" k8s/frontend-deployment.yaml


                            # Configure Git identity
                            git config user.name "Jenkins"
                            git config user.email "jenkins@localhost"


                            echo ""
                            echo "Git changes:"
                            git diff


                            # Stage Kubernetes manifest changes
                            git add \
                                k8s/backend-deployment.yaml \
                                k8s/frontend-deployment.yaml


                            # Commit changes
                            git commit \
                                -m "chore: update EMS images to build ${IMAGE_TAG}"


                            echo ""
                            echo "Pushing GitOps changes..."

                            git push origin ${GITOPS_BRANCH}
                        }
                    }
                }
            }
        }
    }


    // ================================================================
    // POST ACTIONS
    // ================================================================

    post {

        success {

            echo """
            ================================================
            EMS CI + GitOps Pipeline Completed Successfully
            ================================================

            Docker Images:
              ${BACKEND_IMAGE}:${IMAGE_TAG}
              ${FRONTEND_IMAGE}:${IMAGE_TAG}

            GitOps Repository:
              ${GITOPS_REPO}

            Next:
              Argo CD detects the GitOps change
              Argo CD synchronizes Kubernetes
              Kubernetes deploys the new EMS version

            Jenkins does NOT directly deploy to Kubernetes.
            ================================================
            """
        }


        failure {

            echo """
            ================================================
            EMS Pipeline Failed
            ================================================

            Check the failed stage above.

            ================================================
            """
        }


        unstable {
            echo 'Pipeline Unstable'
        }


        aborted {
            echo 'Pipeline Aborted'
        }


        always {

            sh """
                docker image prune -f
            """
        }
    }
}