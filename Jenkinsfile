pipeline {
    agent any

    tools {
        jdk 'Java17'
        maven 'Maven3'
    }

    environment {
        JAR_NAME = 'spring-boot-data-jpa-0.0.1-SNAPSHOT.jar'
        DEPLOY_DIR = '/opt/backend'
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
                sh 'mvn clean install -DskipTests'
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
                        mkdir -p /opt/backend

                        cp target/${JAR_NAME} /opt/backend/${JAR_NAME}

                        # Stop existing app if running
                        pkill -f ${JAR_NAME} || true
                        sleep 3

                        # Start app as background service
                        export JENKINS_NODE_COOKIE=dontKillMe
                        nohup java -jar /opt/backend/${JAR_NAME} \
                            --server.port=8081 \
                            --spring.datasource.url=${DB_URL} \
                            --spring.datasource.username=${DB_USERNAME} \
                            --spring.datasource.password=${DB_PASSWORD} \
                            > /opt/backend/app.log 2>&1 &

                        echo $! > /opt/backend/app.pid
                        echo "Backend started with PID: $(cat /opt/backend/app.pid)"
                        sleep 5

                        # Verify app is running
                        if ps -p $(cat /opt/backend/app.pid) > /dev/null; then
                            echo "✅ App is running!"
                        else
                            echo "❌ App failed to start!"
                            cat /opt/backend/app.log
                            exit 1
                        fi
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