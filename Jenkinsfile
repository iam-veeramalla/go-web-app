pipeline {
    agent any

    tools {
        go 'go-1.22.5'
    }

    environment {
        SCANNER_HOME = tool 'sonar-scanner'
        SONAR_TOKEN = credentials('sonar-cred')
        GITHUB_TOKEN = credentials('git-cred') // Your GitHub token
        DOCKER_CREDENTIALS = credentials('docker-cred') // Docker credentials
    }

    stages {
        stage('Checkout Code') {
            steps {
                script {
                    // Use the GitHub token for authentication
                    withCredentials([string(credentialsId: 'git-cred', variable: 'GITHUB_TOKEN')]) {
                        sh '''
                        git config --global url."https://github.com/".insteadOf git@github.com:
                        git config --global user.email "vinaychowdarychitturi@gmail.com"
                        git config --global user.name "vinnu2251"
                        git clone https://github.com/vinnu2251/go-web-app.git
                        cd go-web-app
                        '''
                    }
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
                    def commitId = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                    withDockerRegistry(credentialsId: 'docker-cred') {
                        sh "docker build -t vinay7944/go-web-app:${commitId} ."
                    }
                }
            }
        }

        stage('Docker Push Image') {
            steps {
                script {
                    def commitId = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                    withDockerRegistry(credentialsId: 'docker-cred') {
                        sh "docker push vinay7944/go-web-app:${commitId}"
                    }
                }
            }
        }

        stage('Update Helm Chart with Commit ID') {
            steps {
                script {
                    def commitId = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                    sh """
                    sed -i 's/tag: .*/tag: "${commitId}"/' helm/go-web-app-chart/values.yaml
                    git add helm/go-web-app-chart/values.yaml
                    git commit -m "Update tag in Helm chart with commit ID ${commitId}"
                    git push origin main
                    """
                }
            }
        }
    }

    post {
        always {
            echo "Pipeline completed"
        }
    }
}
