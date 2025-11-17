pipeline {
    agent any

    parameters {
        string(name: 'DOCKER_HOST', defaultValue: 'tcp://192.168.56.20:2375', description: 'Docker Host (твоя ВМ)')
    }

    environment {
        DOCKER_HOST       = "${params.DOCKER_HOST}"
        REGISTRY          = 'docker.io'
        FRONTEND_IMAGE    = 'anastasiia191006/userstory-frontend:latest'
        BACKEND_IMAGE     = 'anastasiia191006/userstory-backend:latest'
    }

    stages {
        // 1. Тільки збираємо Maven (jar)
        stage('Build Backend JAR') {
            steps {
                dir('backend') {
                    sh 'mvn clean package -DskipTests'
                }
            }
        }

        // 2. Збираємо та пушимо обидва Docker-образи
        stage('Build & Push Docker Images') {
            steps {
                script {
                    // Логін в Docker Hub
                    withCredentials([usernamePassword(
                        credentialsId: 'docker-registry-credentials',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASS'
                    )]) {
                        sh "docker -H ${DOCKER_HOST} login -u $DOCKER_USER -p $DOCKER_PASS ${REGISTRY}"
                    }

                    // Frontend (multi-stage Dockerfile сам робить npm install + build)
                    sh "docker -H ${DOCKER_HOST} build -t ${FRONTEND_IMAGE} ./frontend"
                    sh "docker -H ${DOCKER_HOST} push ${FRONTEND_IMAGE}"

                    // Backend
                    sh "docker -H ${DOCKER_HOST} build -t ${BACKEND_IMAGE} ./backend"
                    sh "docker -H ${DOCKER_HOST} push ${BACKEND_IMAGE}"
                }
            }
        }

        // 3. Деплой на твою ВМ
        stage('Deploy with Docker Compose') {
            steps {
                script {
                    // Тягнемо нові образи, зупиняємо старі контейнери і запускаємо нові
                    sh """
                        docker-compose -H ${DOCKER_HOST} -f docker-compose.yml pull
                        docker-compose -H ${DOCKER_HOST} -f docker-compose.yml down --remove-orphans || true
                        docker-compose -H ${DOCKER_HOST} -f docker-compose.yml up -d
                    """
                }
            }
        }
    }

    post {
        always {
            sh "docker -H ${DOCKER_HOST} logout || true"
            cleanWs()
        }
        success {
            echo "УСІ СЕРВІСИ ЗАПУЩЕНО!"
            echo "Frontend:  http://192.168.56.20"
            echo "Backend:   http://192.168.56.20:8080"
            echo "База:      192.168.56.20:3306 (userstory_user / userstory_pass)"
        }
        failure {
            echo "Щось пішло не так. Перевіряй логи вище."
        }
    }
}
