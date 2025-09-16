pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION    = "us-east-1"
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/Maresh971/infra-ansible-jenkins.git'
            }
        }

        stage('Terraform Init & Apply') {
            steps {
                sh '''
                    terraform fmt -recursive
                    terraform validate
                    terraform init -input=false
                    terraform apply -auto-approve -input=false
                '''
            }
        }

        stage('Ansible Provisioning') {
            steps {
                script {
                    def ec2_ip = sh(script: "terraform output -raw ec2_public_ip", returnStdout: true).trim()

                    withCredentials([sshUserPrivateKey(credentialsId: 'ansible12', keyFileVariable: 'SSH_KEY', usernameVariable: 'SSH_USER')]) {
                        writeFile file: 'inventory.ini',
                            text: "[ec2]\n${ec2_ip} ansible_user=${SSH_USER} ansible_ssh_private_key_file=${SSH_KEY}"

                        // Wait for SSH to be ready
                        sh """
                            for i in {1..10}; do
                                if ssh -o StrictHostKeyChecking=no -i ${SSH_KEY} ${SSH_USER}@${ec2_ip} 'echo SSH OK' >/dev/null 2>&1; then
                                    echo '✅ SSH is ready'
                                    break
                                else
                                    echo '⏳ Waiting for SSH... attempt \$i'
                                    sleep 10
                                fi
                            done
                        """

                        sh 'ansible-playbook -i inventory.ini playbook.yml'
                    }
                }
            }
        }

        stage('Verify Nginx') {
            steps {
                script {
                    def ec2_ip = sh(script: "terraform output -raw ec2_public_ip", returnStdout: true).trim()
                    sh """
                        for i in {1..12}; do
                            status_code=\$(curl -o /dev/null -s -w "%{http_code}" http://${ec2_ip})
                            if [ "\$status_code" -eq 200 ]; then
                                echo "✅ Nginx is running on ${ec2_ip}"
                                break
                            else
                                echo "⏳ Waiting for Nginx... attempt \$i"
                                sleep 5
                            fi
                        done
                    """
                }
            }
        }
    }
}
