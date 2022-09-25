pipeline {
agent { label 'tex' }
    stages {
        stage('Build') {
            steps {
                sh 'make'
            }
        }
    }
    post {
        always {
            archiveArtifacts artifacts: 'build/*.pdf', fingerprint: true
        }
    }
}
