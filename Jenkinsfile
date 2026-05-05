pipeline {
    agent any
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        stage('Install & Test') {
            steps {
                sh '''
                python3 -m venv venv
                ./venv/bin/pip install -r requirements.txt
                # Add current directory to PYTHONPATH so tests can see app.py
                export PYTHONPATH=$PYTHONPATH:.
                ./venv/bin/pytest --cov=. --cov-report=xml
                '''
            }
        }

         stage('SonarQube Cloud Analysis') {
            steps {
                script {
                    def scannerHome = tool 'SonarScanner'
                    withSonarQubeEnv('SonarQubeServer') {
                        sh "${scannerHome}/bin/sonar-scanner \
                        -Dsonar.organization=rajeevgangaraju \
                        -Dsonar.projectKey=rajeevgangaraju \
                        -Dsonar.host.url=https://sonarcloud.io"
                    }
                }
            }
        }
        stage('Dependency Scan') {
            steps {
                withCredentials([string(credentialsId: 'NVD_API_KEY', variable: 'NVD_API_KEY')]) {
                    script {
                        sh '''
                          /opt/dependency-check/bin/dependency-check.sh \
                          --project "POC-1" \
                          --scan . \
                          --format XML \
                          --out dependency-check-report \
                          --nvdApiKey $NVD_API_KEY || true
                        '''
                    }
                }
                dependencyCheckPublisher pattern: 'dependency-check-report/dependency-check-report.xml'
            }
        }



         stage('Docker Build & Scan') {
            steps {
                script {
                    // 1. Build the image
                    sh 'docker build -t python-poc-app:latest .'
                    
                    // 2. Scan with Trivy (The Docker Image Scan block in your diagram)
                    sh 'trivy image --severity HIGH,CRITICAL python-poc-app:latest'
                }
            }
        }
        stage('Deploy') {
            steps {
                script {
                    // Remove old container if it exists
                    sh 'docker rm -f running-python-poc || true'
                    
                    // Start the new container on port 8000
                    sh 'docker run -d -p 8000:8000 --name running-python-poc python-poc-app:latest'
                }
            }
        }
    }
}
