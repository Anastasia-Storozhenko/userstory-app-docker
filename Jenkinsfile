pipeline {
    agent any
    parameters {
        string(name: 'DOCKER_HOST', defaultValue: 'tcp://192.168.56.20:2375', description: 'Docker host')
        string(name: 'FRONTEND_IMAGE', defaultValue: '182000022338.dkr.ecr.us-east-1.amazonaws.com/userstory-frontend-repo:latest', description: 'Frontend image')
        string(name: 'BACKEND_IMAGE', defaultValue: '182000022338.dkr.ecr.us-east-1.amazonaws.com/userstory-backend-repo:latest', description: 'Backend image')
    }
    environment {
        DB_USER = credentials('db-credentials')
        DB_USERSTORYPROJ_URL = 'jdbc:mariadb://192.168.56.20:3306/userstory'
        DB_USERSTORYPROJ_USER = "${DB_USER_USR}"
        DB_USERSTORYPROJ_PASSWORD = "${DB_USER_PSW}"
        DOCKER_REGISTRY = 'docker.io'
        DOCKER_CREDENTIALS = credentials('docker-registry-credentials')
        // ВИПРАВЛЕНО: Використовуємо Docker Hub username
        FRONTEND_IMAGE = "${DOCKER_REGISTRY}/anastasiia191006/userstory-frontend:latest"
        BACKEND_IMAGE = "${DOCKER_REGISTRY}/anastasiia191006/userstory-backend:latest"
        DOCKER_HOST = 'tcp://192.168.56.20:2375'
    }
    stages {
        stage('Build Frontend') {
            steps {
                dir('frontend') {
                    sh 'npm install'
                    sh 'CI=false npm run build'
                }
            }
        }
        stage('Build Backend') {
            steps {
                dir('backend') {
                    sh 'mvn clean package -DskipTests'
                }
            }
        }
        stage('Build Docker Images') {
            steps {
                script {
                    sh "docker -H ${DOCKER_HOST} build -t ${FRONTEND_IMAGE} ./frontend"
                    sh "docker -H ${DOCKER_HOST} build -t ${BACKEND_IMAGE} ./backend"
                }
            }
        }
        stage('Deploy') {
            steps {
                script {
                    sh "docker-compose -H ${DOCKER_HOST} -f ./docker-compose.yml down || true"
                    sh "docker-compose -H ${DOCKER_HOST} -f ./docker-compose.yml up -d"
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
