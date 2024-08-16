pipeline {
    agent any

    tools {
        go 'go-1.22.5'
    }

    environment {
        SCANNER_HOME = tool 'sonar-scanner'
        SONAR_TOKEN = credentials('sonar-cred')
        GITHUB_TOKEN = credentials('git-cred')
    }

    stages {
        stage('Checkout') {
            steps {
                // Checkout the code from the GitHub repository
                checkout scm
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

        stage('Docker Build & Tag') {
            steps {
                script {
                    // Get the short commit ID
                    COMMIT_ID = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
                    echo "Commit ID: ${COMMIT_ID}"
                    // Build and tag the Docker image using the commit ID
                    withDockerRegistry(credentialsId: 'docker-cred', toolName: 'docker') {
                        sh "docker build -t vinay7944/go-web-app:${COMMIT_ID} ."
                    }
                }
            }
        }

        stage('Docker Push Image') {
            steps {
                script {
                    // Push the Docker image to Docker Hub
                    withDockerRegistry(credentialsId: 'docker-cred', toolName: 'docker') {
                        sh "docker push vinay7944/go-web-app:${COMMIT_ID}"
                    }
                }
            }
        }

        stage('Update Helm Chart with Commit ID') {
            steps {
                script {
                    // Update the Helm chart values with the new Docker image tag (commit ID)
                    sh "sed -i 's/tag: .*/tag: \"${COMMIT_ID}\"/' helm/go-web-app-chart/values.yaml"
                    
                    // Commit and push the changes to the Helm chart
                    sh """
                        git config --global user.email "vinaychowdarychitturi@gmail.com"
                        git config --global user.name "vinnu2251"
                        git add helm/go-web-app-chart/values.yaml
                        git commit -m "Update tag in Helm chart with commit ID ${COMMIT_ID}"
                        git push origin main
                    """
                }
            }
        }
    }

    post {
        always {
            echo "Pipeline complete."
        }
    }
}
