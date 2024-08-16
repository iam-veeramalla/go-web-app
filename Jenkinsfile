pipeline {
    agent any

    tools {
        go 'go-1.22.5'
    }

    environment {
        SCANNER_HOME = tool 'sonar-scanner'
        SONAR_TOKEN = credentials('sonar-cred')
        GITHUB_TOKEN = credentials('git-cred') // Jenkins credential ID for the GitHub token
        DOCKER_CRED = credentials('docker-cred') // Docker credentials
    }

    stages {
        stage('Checkout Code') {
            steps {
                script {
                    // Checkout the repository
                    checkout scm

                    // Configure Git for Jenkins
                    sh """
                    git config --global user.email "vinaychowdarychitturi@gmail.com"
                    git config --global user.name "vinay chitturi"
                    """

                    // Debugging steps
                    sh 'git status'           // Show current status of the working directory
                    sh 'git branch -a'        // List all branches
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

        stage('Docker Build & Tag') {
            steps {
                script {
                    withDockerRegistry(credentialsId: 'docker-cred', toolName: 'docker') {
                        sh 'docker build -t vinay7944/go-web-app:v1 .'
                    }
                }
            }
        }

        stage('Docker Push Image') {
            steps {
                script {
                    withDockerRegistry(credentialsId: 'docker-cred', toolName: 'docker') {
                        sh 'docker push vinay7944/go-web-app:v1'
                    }
                }
            }
        }

        stage('Update Helm Chart Tag') {
            steps {
                script {
                    // Get the current branch name
                    def branchName = sh(script: 'git rev-parse --abbrev-ref HEAD', returnStdout: true).trim()
                    echo "Current branch: ${branchName}"

                    // Debugging steps for updating Helm chart
                    sh """
                    echo "Current directory:"
                    pwd
                    echo "Listing files:"
                    ls -l
                    echo "Checking Helm chart values:"
                    cat helm/go-web-app-chart/values.yaml
                    echo "Updating tag in Helm chart"
                    sed -i 's/tag: .*/tag: "${BUILD_NUMBER}"/' helm/go-web-app-chart/values.yaml
                    echo "Updated Helm chart values:"
                    cat helm/go-web-app-chart/values.yaml
                    """

                    // Add, commit, and push changes
                    sh """
                    git add helm/go-web-app-chart/values.yaml
                    git commit -m "Update tag in Helm chart"
                    git push origin ${branchName}
                    """
                }
            }
        }
    }

    post {
        always {
            echo "Pipeline complete"
            cleanWs() // Clean workspace after the build
        }
    }
}
