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
                    COMMIT_ID = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                    sh 'docker build -t vinay7944/go-web-app:${COMMIT_ID} .'
                }
            }
        }

        stage('Docker Push Image') {
            steps {
                script {
                    withDockerRegistry(credentialsId: 'docker-cred', toolName: 'docker') {
                        sh "docker push vinay7944/go-web-app:${COMMIT_ID}"
                    }
                }
            }
        }

        stage('Update Helm Chart with Commit ID') {
            steps {
                script {
                    sh "git checkout main" // Ensures you are on the main branch
                    sh "sed -i 's/tag: .*/tag: \"${COMMIT_ID}\"/' helm/go-web-app-chart/values.yaml"
                    sh 'git config --global user.email "vinaychowdarychitturi@gmail.com"'
                    sh 'git config --global user.name "vinnu2251"'
                    sh "git add helm/go-web-app-chart/values.yaml"
                    sh "git commit -m 'Update tag in Helm chart with commit ID ${COMMIT_ID}'"
                    sh "git push origin main"
                }
            }
        }
    }

    post {
        always {
            echo "Pipeline execution completed."
        }
    }
}
