pipeline {
    agent any

    tools {
        jdk 'Java17'
        maven 'Maven3'
    }

    environment {
        JAR_NAME = 'spring-boot-data-jpa-0.0.1-SNAPSHOT.jar'
        DEPLOY_DIR = '/home/azureuser/backend'
    }

    stages {

        stage('Checkout') {
            steps {
                echo '=== Pulling latest code from GitHub ==='
                checkout scm
            }
        }

        stage('Build') {
            steps {
                echo '=== Building JAR with Maven ==='
                sh '/usr/share/maven/bin/mvn clean install -DskipTests'
            }
        }

        stage('Deploy') {
            steps {
                echo '=== Deploying Spring Boot ==='
                withCredentials([
                    string(credentialsId: 'DB_URL', variable: 'DB_URL'),
                    string(credentialsId: 'DB_USERNAME', variable: 'DB_USERNAME'),
                    string(credentialsId: 'DB_PASSWORD', variable: 'DB_PASSWORD')
                ]) {
                    sh '''
                        mkdir -p ${DEPLOY_DIR}
                        cp target/${JAR_NAME} ${DEPLOY_DIR}/${JAR_NAME}
                        pkill -f ${JAR_NAME} || true
                        sleep 3
                        nohup java -jar ${DEPLOY_DIR}/${JAR_NAME} \
                            --server.port=8081 \
                            --spring.datasource.url=${DB_URL} \
                            --spring.datasource.username=${DB_USERNAME} \
                            --spring.datasource.password=${DB_PASSWORD} \
                            > ${DEPLOY_DIR}/app.log 2>&1 &
                        echo "Backend started on port 8081!"
                    '''
                }
            }
        }
    }

    post {
        success {
            echo '✅ Backend deployed successfully!'
        }
        failure {
            echo '❌ Backend deployment failed!'
        }
    }
}