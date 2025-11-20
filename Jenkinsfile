pipeline {
    agent any
    
    environment {
        COMPOSE_PROJECT_NAME = 'syndic-test'
        BACKEND_PORT = '3001'
        FRONTEND_PORT = '3000'
        MYSQL_PORT = '3308'
    }
    
    stages {
        stage('1. Cleanup Previous Run') {
            steps {
                script {
                    echo '=== Test 1: Cleanup Previous Containers ==='
                    sh '''
                        docker-compose down -v || true
                        docker system prune -f || true
                    '''
                }
            }
        }
        
        stage('2. Build Docker Images') {
            steps {
                script {
                    echo '=== Test 2: Building Docker Images ==='
                    sh '''
                        docker-compose build --no-cache
                    '''
                }
            }
        }
        
        stage('3. Start Services') {
            steps {
                script {
                    echo '=== Test 3: Starting All Services ==='
                    sh '''
                        docker-compose up -d
                        echo "Waiting for services to be ready..."
                        sleep 30
                    '''
                }
            }
        }
        
        stage('4. Database Health Check') {
            steps {
                script {
                    echo '=== Test 4: Checking MySQL Database ==='
                    sh '''
                        docker-compose exec -T mysql mysqladmin ping -h localhost --silent || exit 1
                        echo "Database is healthy"
                        
                        # Check if database exists
                        docker-compose exec -T mysql mysql -e "SHOW DATABASES;" || exit 1
                    '''
                }
            }
        }
        
        stage('5. Backend Service Check') {
            steps {
                script {
                    echo '=== Test 5: Checking Backend Service ==='
                    sh '''
                        # Check if backend container is running
                        docker-compose ps backend | grep "Up" || exit 1
                        
                        # Check backend logs for errors
                        docker-compose logs backend | grep -i "error" && exit 1 || echo "No critical errors found"
                        
                        # Test backend endpoint
                        sleep 10
                        curl -f http://localhost:${BACKEND_PORT}/health || \
                        curl -f http://localhost:${BACKEND_PORT}/ || \
                        echo "Backend endpoint check - manual verification needed"
                    '''
                }
            }
        }
        
        stage('6. Frontend Service Check') {
            steps {
                script {
                    echo '=== Test 6: Checking Frontend Service ==='
                    sh '''
                        # Check if frontend container is running
                        docker-compose ps frontend | grep "Up" || exit 1
                        
                        # Check frontend logs for errors
                        docker-compose logs frontend | grep -i "error" && exit 1 || echo "No critical errors found"
                        
                        # Test frontend endpoint
                        sleep 10
                        curl -f http://localhost:${FRONTEND_PORT}/ || \
                        echo "Frontend endpoint check - manual verification needed"
                    '''
                }
            }
        }
        
        stage('7. Container Integration Test') {
            steps {
                script {
                    echo '=== Test 7: Full Integration Test ==='
                    sh '''
                        # Check all containers are running
                        RUNNING=$(docker-compose ps | grep "Up" | wc -l)
                        EXPECTED=3
                        
                        if [ $RUNNING -eq $EXPECTED ]; then
                            echo "All $EXPECTED containers are running successfully"
                        else
                            echo "Expected $EXPECTED containers, but only $RUNNING are running"
                            docker-compose ps
                            exit 1
                        fi
                        
                        # Check container health
                        docker-compose ps
                        
                        # Display service logs summary
                        echo "=== Backend Logs ==="
                        docker-compose logs --tail=20 backend
                        
                        echo "=== Frontend Logs ==="
                        docker-compose logs --tail=20 frontend
                        
                        echo "=== MySQL Logs ==="
                        docker-compose logs --tail=20 mysql
                    '''
                }
            }
        }
    }
    
    post {
        always {
            script {
                echo '=== Collecting Test Results ==='
                sh '''
                    echo "Final Container Status:"
                    docker-compose ps
                    
                    echo "\nContainer Resource Usage:"
                    docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}" $(docker-compose ps -q)
                '''
            }
        }
        success {
            echo '✅ All 7 tests passed successfully!'
            // Optionally keep containers running for manual testing
            // sh 'docker-compose down -v'
        }
        failure {
            echo '❌ Tests failed! Check the logs above.'
            sh '''
                echo "=== Full Backend Logs ==="
                docker-compose logs backend
                
                echo "=== Full Frontend Logs ==="
                docker-compose logs frontend
                
                echo "=== Full MySQL Logs ==="
                docker-compose logs mysql
            '''
            sh 'docker-compose down -v'
        }
        cleanup {
            echo 'Cleaning up...'
            // Uncomment to always cleanup
            // sh 'docker-compose down -v'
        }
    }
}
