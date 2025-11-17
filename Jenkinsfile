pipeline {
    agent any
    parameters {
        string(name: 'DOCKER_HOST', defaultValue: 'tcp://192.168.56.20:2375', description: 'Docker host')
        string(name: 'FRONTEND_IMAGE', defaultValue: '182000022338.dkr.ecr.us-east-1.amazonaws.com/userstory-frontend-repo:latest', description: 'Frontend image')
        string(name: 'BACKEND_IMAGE', defaultValue: '182000022338.dkr.ecr.us-east-1.amazonaws.com/userstory-backend-repo:latest', description: 'Backend image')
    }
    environment {
        DOCKER_HOST = "${params.DOCKER_HOST}"
        FRONTEND_IMAGE = "${params.FRONTEND_IMAGE}"
        BACKEND_IMAGE = "${params.BACKEND_IMAGE}"
        DOCKER_REGISTRY = '182000022338.dkr.ecr.us-east-1.amazonaws.com'
    }
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', credentialsId: 'github-credentials', url: 'https://github.com/Anastasia-Storozhenko/userstory-app-docker.git'
            }
        }
        stage('Login to ECR') {
            steps {
                withCredentials([
                    string(credentialsId: 'aws-access-key', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'aws-secret-key', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    sh '''
                        export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                        export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
                        export AWS_DEFAULT_REGION=us-east-1
                        aws ecr get-login-password --region us-east-1 | docker -H ${DOCKER_HOST} login --username AWS --password-stdin ${DOCKER_REGISTRY}
                    '''
                }
            }
        }
        stage('Deploy') {
            steps {
                sh '''
                    export FRONTEND_IMAGE=${FRONTEND_IMAGE}
                    export BACKEND_IMAGE=${BACKEND_IMAGE}
                    docker-compose -H ${DOCKER_HOST} down || true
                    docker-compose -H ${DOCKER_HOST} up -d
                '''
                sh 'sleep 100'
                sh 'docker -H ${DOCKER_HOST} ps -a'
            }
        }
        stage('Test API') {
            steps {
                sh 'docker -H ${DOCKER_HOST} exec userstory-frontend curl -s http://backend:8080/projects'
            }
        }
    }
    post {
        always {
            sh "docker -H ${DOCKER_HOST} logout ${DOCKER_REGISTRY} || true"
        }
    }
}
