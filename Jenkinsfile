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
        COMMIT_ID = ""
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout([$class: 'GitSCM', branches: [[name: 'main']], 
                          userRemoteConfigs: [[url: 'git@github.com:vinnu2251/go-web-app.git', 
                                               credentialsId: 'git-ssh-cred']]])
            }
        }

        stage('Build') {
            steps {
                script {
                    COMMIT_ID = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                    sh "go build -o go-web-app"
                }
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
                    withDockerRegistry(credentialsId: 'docker-cred') {
                        sh "docker build -t vinay7944/go-web-app:${COMMIT_ID} ."
                        sh "docker tag vinay7944/go-web-app:${COMMIT_ID} vinay7944/go-web-app:latest"
                    }
                }
            }
        }

        stage('Docker Push Image') {
            steps {
                script {
                    withDockerRegistry(credentialsId: 'docker-cred') {
                        sh "docker push vinay7944/go-web-app:${COMMIT_ID}"
                        sh "docker push vinay7944/go-web-app:latest"
                    }
                }
            }
        }

        stage('Update Helm Chart with Commit ID') {
            steps {
                script {
                    sh "sed -i 's/tag: .*/tag: \"${COMMIT_ID}\"/' helm/go-web-app-chart/values.yaml"
                    sh '''
                        git config --global user.email "vinaychowdarychitturi@gmail.com"
                        git config --global user.name "vinnu2251"
                        git add helm/go-web-app-chart/values.yaml
                        git commit -m "Update tag in Helm chart with commit ID ${COMMIT_ID}"
                        git push origin main
                    '''
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
