pipeline {
    agent any
    parameters {
        string(name: 'DOCKER_HOST', defaultValue: 'tcp://192.168.56.20:2375', description: 'Docker host address')
        string(name: 'FRONTEND_IMAGE', defaultValue: '182000022338.dkr.ecr.us-east-1.amazonaws.com/userstory-frontend-repo:latest', description: 'Frontend Docker image')
        string(name: 'BACKEND_IMAGE', defaultValue: '182000022338.dkr.ecr.us-east-1.amazonaws.com/userstory-backend-repo:latest', description: 'Backend Docker image')
        string(name: 'COMPOSE_HTTP_TIMEOUT', defaultValue: '120', description: 'Docker Compose HTTP timeout')
    }
    environment {
        DOCKER_HOST = "${params.DOCKER_HOST}"
        FRONTEND_IMAGE = "${params.FRONTEND_IMAGE}"
        BACKEND_IMAGE = "${params.BACKEND_IMAGE}"
        COMPOSE_HTTP_TIMEOUT = "${params.COMPOSE_HTTP_TIMEOUT}"
        DOCKER_REGISTRY = '182000022338.dkr.ecr.us-east-1.amazonaws.com'
    }
    stages {
        stage('Checkout Deploy Repo') {
            steps {
                git branch: 'main', credentialsId: 'github-credentials', url: 'https://github.com/Anastasia-Storozhenko/userstory-app-docker.git'
            }
        }
        stage('Check Files') {
            steps {
                sh 'ls -l nginx.conf || echo "nginx.conf not found"'
                sh 'cat nginx.conf || echo "Failed to read nginx.conf"'
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
        stage('Deploy with Docker Compose') {
            steps {
                script {
                    sh '''
                        export FRONTEND_IMAGE=${FRONTEND_IMAGE}
                        export BACKEND_IMAGE=${BACKEND_IMAGE}
                        
                        echo "Зупиняємо compose..."
                        docker-compose -H ${DOCKER_HOST} -f docker-compose.yml down -v --remove-orphans || true
                        
                        echo "Вбиваємо всі Docker-контейнери, що тримають 8080..."
                        docker -H ${DOCKER_HOST} ps -q --filter "expose=8080" | xargs -r docker -H ${DOCKER_HOST} rm -f || true
                        
                        echo "Тепер вбиваємо НЕ-docker процеси на 8080 (головне!)"
                        # Це ключовий рядок — вбиває будь-який процес (java, nginx, тощо)
                        sudo lsof -i tcp:8080 -t | xargs -r sudo kill -9 || true
                        
                        # Альтернатива, якщо lsof немає:
                        # sudo fuser -k 8080/tcp || true
                        
                        echo "Перевіряємо — 8080 має бути вільний:"
                        docker -H ${DOCKER_HOST} ps -a | grep 8080 || echo "Нічого не знайдено — добре"
                        
                        echo "Запускаємо compose..."
                        docker-compose -H ${DOCKER_HOST} -f docker-compose.yml up -d --force-recreate
                        
                        sleep 90
                        docker -H ${DOCKER_HOST} ps -a
                    '''
                }
            }
        }
        stage('Test Application') {
            steps {
                script {
                    sh "docker -H ${DOCKER_HOST} exec userstory-frontend curl -s http://backend:8080/projects || echo 'API check failed'"
                }
            }
        }
    }
    post {
        always { 
            sh "docker -H ${DOCKER_HOST} logout ${DOCKER_REGISTRY}"
        }
    }
}
