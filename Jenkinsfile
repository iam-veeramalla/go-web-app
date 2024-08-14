pipeline {
    agent any

   tools {
       go 'go-1.22.5'
    }


    environment {

        SCANNER_HOME = tool 'sonar-scanner'
        SONAR_TOKEN = credentials('sonar-cred')

        }

     stages {

        stage('Build'){
                steps{
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
                script {
                    sh '''
                        ${SCANNER_HOME}/bin/sonar-scanner \
                          -Dsonar.projectKey=gowebapp \
                          -Dsonar.sources=. \
                          -Dsonar.host.url=http://localhost:9000 \
                          -Dsonar.login=${SONAR_TOKEN}
                    '''
                }
            }
        }

        stage('Docker Build & Tag') {
                        steps {

                                script {
                                        withDockerRegistry(credentialsId: 'docker-cred', toolName: 'docker') 
                                        {
                                                sh 'docker build -t vinay7944/go-web-app:latest .'
                                        }
                                }
                        }
                }

        stage('Docker Push image'){
                        steps{
                                script{
                                        withDockerRegistry(credentialsId: 'docker-cred',toolName: 'docker'){
                                                sh "docker push vinay7944/go-web-app:latest"
                                        } 
                                }
                        }
                }


     }


        post{
            always{
                    echo "complete"
            }
        }
}
