pipeline {
    agent any

    tools {
        go 'go-1.22.5'
    }

    environment {
        SCANNER_HOME = tool 'sonar-scanner'
        SONAR_TOKEN = credentials('sonar-cred')
        GITHUB_TOKEN = credentials('git-cred') // Jenkins credential ID for the GitHub token
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
                    // Checkout the repository
                    checkout scm

                    // Update tag in Helm chart
                    sh '''
                        sed -i 's/tag: .*/tag: "${BUILD_NUMBER}"/' helm/go-web-app-chart/values.yaml
                    '''

                    // Configure Git and commit changes
                    sh '''
                        git config --global user.email "vinaychowdarychitturi@gmail.com"
                        git config --global user.name "vinay chitturi"
                        git add helm/go-web-app-chart/values.yaml
                        git commit -m "Update tag in Helm chart"
                    '''

                    // Push changes to the repository
                    withCredentials([usernamePassword(credentialsId: 'git-cred', usernameVariable: 'GIT_USERNAME', passwordVariable: 'GIT_PASSWORD')]) {
                        sh '''
                            git push https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/vinnu2251/go-web-app.git
                        '''
                    }
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
