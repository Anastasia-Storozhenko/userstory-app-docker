pipeline {
    agent any

    parameters {
        string(name: 'DOCKER_HOST', defaultValue: 'tcp://192.168.56.20:2375', description: 'Твоя ВМ з Docker')
    }

    environment {
        DOCKER_HOST       = "${params.DOCKER_HOST}"
        REGISTRY          = 'docker.io'
        FRONTEND_IMAGE    = 'anastasiia191006/userstory-frontend:latest'
        BACKEND_IMAGE     = 'anastasiia191006/userstory-backend:latest'
    }

    stages {
        // ВСІ збірки тепер через Docker — Jenkins-агенту більше нічого не треба!
        stage('Build & Push Images') {
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

                    // 1. Frontend — multi-stage Dockerfile сам робить npm install + build
                    sh "docker -H ${DOCKER_HOST} build -t ${FRONTEND_IMAGE} ./frontend"
                    sh "docker -H ${DOCKER_HOST} push ${FRONTEND_IMAGE}"

                    // 2. Backend — multi-stage Dockerfile сам робить mvn package
                    sh "docker -H ${DOCKER_HOST} build -t ${BACKEND_IMAGE} ./backend"
                    sh "docker -H ${DOCKER_HOST} push ${BACKEND_IMAGE}"
                }
            }
        }

        // Деплой
        stage('Deploy') {
            steps {
                script {
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
            sh 'docker -H ${DOCKER_HOST} logout || true'
            cleanWs()
        }
        success {
            echo "ГОТОВО! Все запущено на http://192.168.56.20"
        }
    }
}
