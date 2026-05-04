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

    // Run OWASP Dependency-Check using Jenkins plugin
    dependencyCheck(
      odcInstallation: 'Dependency-Check',   // must match Global Tool Configuration name
      additionalArguments: '''
        --project "POC-1"
        --scan .
        --out dependency-check-report
        --format XML
        --format HTML
        --noupdate
      ''',
      stopBuild: false   // keep build green even if vulnerabilities are found
    )

    // Publish the Dependency-Check report in Jenkins
    dependencyCheckPublisher(
      pattern: 'dependency-check-report/dependency-check-report.xml'
    )
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
