pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION    = "us-east-1"
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')      // Jenkins credentials ID
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')  // Jenkins credentials ID
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/Maresh971/infra-ansible-jenkins.git'
            }
        }

        stage('Terraform Init & Apply') {
            steps {
                dir('terraform') {
                    sh 'terraform init'
                    sh 'terraform apply -auto-approve'
                }
            }
        }

        stage('Ansible Provisioning') {
            steps {
                script {
                    // Get EC2 public IP from Terraform output
                    def ec2_ip = sh(script: "cd terraform && terraform output -raw ec2_public_ip", returnStdout: true).trim()

                    // Create dynamic Ansible inventory
                    writeFile file: 'ansible/inventory.ini', text: "[ec2]\n${ec2_ip} ansible_user=ubuntu ansible_ssh_private_key_file=/var/lib/jenkins/workspace/aws-key.pem"

                    // Run Ansible playbook
                    sh 'ansible-playbook -i ansible/inventory.ini ansible/playbook.yml'
                }
            }
        }

        stage('Verify Nginx') {
            steps {
                script {
                    def ec2_ip = sh(script: "cd terraform && terraform output -raw ec2_public_ip", returnStdout: true).trim()
                    sh "curl -I http://${ec2_ip}"
                }
            }
        }
    }
}
