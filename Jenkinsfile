pipeline {
    agent any

    tools {
        go 'go-1.22.5'
    }

    environment {
        SCANNER_HOME = tool 'sonar-scanner'
        SONAR_TOKEN = credentials('sonar-cred')
        GITHUB_TOKEN = credentials('git-cred')
        DOCKER_CRED = credentials('docker-cred')
    }

    stages {
        stage('Checkout Code') {
            steps {
                script {
                    // Checkout the main branch
                    checkout scm
                }
            }
        }

        stage('Build') {
            steps {
                sh "go build -o go-web-app"
            }
        }

        stage('Unit Test') {
            steps {
                sh "go test ./..."
            }
        }

        stage('Run SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonar') {
                    sh "${SCANNER_HOME}/bin/sonar-scanner -Dsonar.projectKey=gowebapp -Dsonar.projectName=gowebapp"
                }
            }
        }

        stage('Get Commit ID') {
            steps {
                script {
                    // Get the commit ID
                    env.COMMIT_ID = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                }
            }
        }

        stage('Docker Build & Tag') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'docker-cred', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                        sh """
                            docker build -t ${DOCKER_USERNAME}/go-web-app:${env.COMMIT_ID} .
                            docker tag ${DOCKER_USERNAME}/go-web-app:${env.COMMIT_ID} ${DOCKER_USERNAME}/go-web-app:latest
                        """
                    }
                }
            }
        }

        stage('Docker Push Image') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'docker-cred', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                        sh """
                            echo ${DOCKER_PASSWORD} | docker login --username ${DOCKER_USERNAME} --password-stdin
                            docker push ${DOCKER_USERNAME}/go-web-app:${env.COMMIT_ID}
                            docker push ${DOCKER_USERNAME}/go-web-app:latest
                        """
                    }
                }
            }
        }

        stage('Update Helm Chart Tag') {
            steps {
                script {
                    // Update tag in Helm chart with commit ID
                    sh """
                        sed -i 's/tag: .*/tag: "${env.COMMIT_ID}"/' helm/go-web-app-chart/values.yaml
                    """

                    // Configure Git and commit changes
                    sh """
                        git config --global user.email "vinaychowdarychitturi@gmail.com"
                        git config --global user.name "vinnu2251"
                        git add helm/go-web-app-chart/values.yaml
                        git commit -m "Update tag in Helm chart with commit ID ${env.COMMIT_ID}"
                        git push origin main
                    """
                }
            }
        }
    }

    post {
        always {
            echo "Complete"
        }
    }
}
