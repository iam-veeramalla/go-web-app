pipeline {
    agent any

    tools {
        go 'go-1.22.5'
    }

    environment {
        SCANNER_HOME = tool 'sonar-scanner'
        SONAR_TOKEN = credentials('sonar-cred')
        GITHUB_TOKEN = credentials('git-cred')
        DOCKER_USERNAME = 'vinay7944'
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
                    sh "docker build -t ${DOCKER_USERNAME}/go-web-app:${COMMIT_ID} ."
                }
            }
        }

        stage('Docker Push Image') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'docker-cred', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                        sh """
                            echo ${DOCKER_PASSWORD} | docker login --username ${DOCKER_USERNAME} --password-stdin
                            docker push ${DOCKER_USERNAME}/go-web-app:${COMMIT_ID}
                        """
                    }
                }
            }
        }

        stage('Update Helm Chart with Commit ID') {
            steps {
                script {
                    sh "sed -i 's/tag: .*/tag: \"${COMMIT_ID}\"/' helm/go-web-app-chart/values.yaml"
                    sh "git config --global user.email 'vinaychowdarychitturi@gmail.com'"
                    sh "git config --global user.name 'vinnu2251'"
                    sh "git add helm/go-web-app-chart/values.yaml"
                    sh "git commit -m 'Update tag in Helm chart with commit ID ${COMMIT_ID}'"
                    sh "git push origin ${env.BRANCH_NAME}"
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
