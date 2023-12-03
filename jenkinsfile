pipeline {
    agent none

    environment {
        MYSQL_HOST = 'mysql-flexible-server.mysql.database.azure.com'
        MYSQL_PORT = '3306'
        MYSQL_USER = 'mysqladmin'
        MYSQL_PASSWORD = 'Canarys@123'
        MYSQL_DATABASE = 'MyShuttleDb'
        AZURE_WEBAPP_NAME = 'myshuttle-team4'
        AZURE_RESOURCE_GROUP = 'devopsathon4-rg'
        AZURE_PLAN_NAME = 'myshuttle-plan'
        ARTIFACT_PATH = 'target/*.war'
        AZURE_CLIENT_ID = 'c7f59d11-4e5e-4c7b-b25d-9093238144bc'
        AZURE_CLIENT_SECRET = 'e1Z8Q~KX~KcwRolI8vdiumoVJ8U4YNfqYo-XRbUi'
        AZURE_TENANT_ID = '0c88fa98-b222-4fd8-9414-559fa424ce64'
        AZURE_CONFIG_DIR = "$WORKSPACE/.azure"  // Set the Azure CLI configuration directory
    }

    stages {
        stage('Build') {
            agent {
                docker {
                    image 'maven:3.6.1-jdk-8'
                    args '--user root -v /var/run/docker.sock:/var/run/docker.sock'
                }
            }
            steps {
                echo 'Checking out the code and building and generating artifacts'
                git branch: 'main', url: 'https://github.com/team4canarys/myshuttle.git'
                script {
                    sh 'mvn clean install -Dmaven.test.skip=true'
                }
                archiveArtifacts 'target/*.war'
            }
        }
        
        stage('Infra') {
            agent {
                docker {
                    image 'hashicorp/terraform:light'
                    args '--entrypoint=/usr/bin/env -e PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'
                  
                }
            }
           
            steps {
                script {                   
                    // Continue with your Terraform initialization and deployment steps
                    git branch: 'main', url: 'https://github.com/team4canarys/myshuttle.git'
                    sh 'ls -la $WORKSPACE/Terraform' // List files in the directory for debugging
                    sh 'cd $WORKSPACE/Terraform && terraform init'
                    sh 'cd $WORKSPACE/Terraform && terraform plan'
                    sh 'cd $WORKSPACE/Terraform && terraform apply -auto-approve'
                }
            }
        }
        
        stage('DeployToMySQL') {
            agent {
                docker {
                    image 'mysql:5.7'
                }
            }
            steps {
                script {
                    git branch: 'main', url: 'https://github.com/team4canarys/myshuttle.git'
                    def sqlscriptpath = "$WORKSPACE/CreateMYSQLDB.sql"
                    sh "mysql -h $MYSQL_HOST -u $MYSQL_USER -p'$MYSQL_PASSWORD' $MYSQL_DATABASE < $sqlscriptpath"
                }
            }
        }

        stage('DeployToAzureAppService') {
            agent {
                docker {
                    image 'mcr.microsoft.com/azure-cli'
                }
            }
            steps {
                script {
                    echo 'Deploying to Azure App Service'
                    try {
                        sh "export AZURE_CONFIG_DIR=$AZURE_CONFIG_DIR && az login --service-principal --username $AZURE_CLIENT_ID --password $AZURE_CLIENT_SECRET --tenant $AZURE_TENANT_ID"
                        sh "az webapp deployment source config-zip --resource-group $AZURE_RESOURCE_GROUP --name $AZURE_WEBAPP_NAME --src $WORKSPACE/$ARTIFACT_PATH"
                    } catch (Exception e) {
                        currentBuild.result = 'FAILURE'
                        echo "Azure deployment failed: ${e.message}"
                    }
                }
            }
        }
    }
}
