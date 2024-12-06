pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID      = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY  = credentials('bahgataws')
        AWS_DEFAULT_REGION     = 'eu-north-1'
        AWS_ACCOUNT_ID         = '908027402088'
        ECR_REPO               = 'bahgat/augustus'
        REPO_URL               = 'https://github.com/bahgat1911/Augustus.git'
        APP_NAME               = 'node__image'
        IMAGE_TAG              = "latest"
        EC2_USER               = 'ec2-user'
        EC2_HOST               = '13.51.86.33'
        DOCKER_COMPOSE_PATH    = '/home/ec2-user/docker-compose.yml'
        DOCKERFILE_PATH        = './devops-task1/Dockerfile.backend'
        AWS_ECR_URL            = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"
    }

    stages {
        stage('Clone Repository') {
            steps {
                git branch: 'master', url: "${REPO_URL}"
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh """
                    docker build -f ${DOCKERFILE_PATH} -t ${APP_NAME}:${IMAGE_TAG} ./devops-task1
                    docker tag ${APP_NAME}:${IMAGE_TAG} ${AWS_ECR_URL}/${ECR_REPO}:${IMAGE_TAG}
                    """
                }
            }
        }

        stage('Login to Amazon ECR') {
            steps {
                sh """
                aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | \
                docker login --username AWS --password-stdin ${AWS_ECR_URL}
                """
            }
        }

        stage('Push to AWS ECR') {
            steps {
                script {
                    sh """
                    docker push ${AWS_ECR_URL}/${ECR_REPO}:${IMAGE_TAG}
                    """
                }
            }
        }

        stage('Deploy on EC2') {
            steps {
                script {
                    sshagent(['ec2-ssh-key']) {
                        sh '''
                        ssh -o StrictHostKeyChecking=no ${EC2_USER}@${EC2_HOST} << EOF
                        aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | \
                        docker login --username AWS --password-stdin ${AWS_ECR_URL}

                        # Pull the latest image from ECR
                        docker pull ${AWS_ECR_URL}/${ECR_REPO}:${IMAGE_TAG}

                        # Restart services using Docker Compose
                        cd /home/ec2-user/
                        docker-compose -f ${DOCKER_COMPOSE_PATH} down
                        docker-compose -f ${DOCKER_COMPOSE_PATH} up -d
                        << EOF'''
                    
                    }
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
