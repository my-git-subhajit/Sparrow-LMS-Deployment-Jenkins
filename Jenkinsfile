def COLOR_MAP = [
    'FAILURE' : 'danger',
    'SUCCESS' : 'good'
]

pipeline {
    agent any
    
    parameters {
        string(name: 'DEPLOY_COMPONENT', defaultValue: '', description: 'Component to deploy: Backend, Frontend, Landing')
        string(name: 'COMPONENT_TAG', defaultValue: '', description: 'Tag of the component to deploy')
        choice(name: 'ACTION', choices: ['deploy', 'destroy'], description: 'Action to perform: deploy or destroy')
    }

    environment {
        GITHUB_PAT = credentials('github')
        GITHUB_URL = 'https://github.com/my-git-subhajit/Sparrow-LMS-Deployment-Jenkins.git'
        GIT_BRANCH = 'main'
        
        AWS_REGION1 = "us-east-1"
        AWS_REGION2 = "us-east-2"
		
		KUBECONFIG1 = "arn:aws:eks:us-east-1:730335428144:cluster/lms-cluster-region1"
		KUBECONFIG2 = "arn:aws:eks:us-east-2:730335428144:cluster/lms-cluster-region2"

        AWS_EKS_CLUSTER_NAME_REGION1 = "lms-cluster-region1"
        AWS_EKS_CLUSTER_NAME_REGION2 = "lms-cluster-region2"

        HELM_CHART_BE_PATH = './lms-sparrow-be-chart'
        HELM_RELEASE_BE_NAME = 'lms-sparrow-be-chart'

        HELM_CHART_FE_PATH = './lms-sparrow-fe-chart'
        HELM_RELEASE_FE_NAME = 'lms-sparrow-fe-chart'

        HELM_CHART_UI_PATH = './lms-sparrow-ui-chart'
        HELM_RELEASE_UI_NAME = 'lms-sparrow-ui-chart'

        HELM_CHART_COMPILER_PATH = './lms-sparrow-compiler-chart'
        HELM_RELEASE_COMPILER_NAME = 'lms-sparrow-compiler-chart'
        
    }
    stages {
        stage('Parameter Validation') {
            when {
                expression { params.ACTION == 'deploy' }
            }
            steps {
                script {
                    if (!['Sparrow LMS Deployment Backend', 'Sparrow LMS Deployment Frontend', 'Sparrow LMS Deployment Landing'].contains(params.DEPLOY_COMPONENT)) {
                        error "Invalid component specified for deployment: ${params.DEPLOY_COMPONENT}"
                    }
                }
            }
        }
        stage('Checkout') {
            steps {
                script {
                    try {
                        checkout([$class: 'GitSCM', branches: [[name: env.GIT_BRANCH]], userRemoteConfigs: [[url:  env.GITHUB_URL, credentialsId: 'github']]])
                    } catch (err) {
                        echo "Error during Git checkout: ${err.message}"
                        currentBuild.result = 'FAILURE'
                        error "Stopping pipeline due to Git checkout error."
                    }
                }
            }
        }
        stage('Terraform Initialize') {
            steps {
                dir('terraform') {
                    script {
                        try {
                            withCredentials([aws(credentialsId: 'aws-config')]) {
                                sh 'terraform init'
                            }
                        } catch (err) {
                            echo "Error during Terraform initialization: ${err.message}"
                            currentBuild.result = 'FAILURE'
                            error "Stopping pipeline due to Terraform initialization error."
                        }
                    }
                }
            }
        }
        
        stage('Format terraform code') {
            when {
                expression { params.ACTION == 'deploy' }
            }
            steps {
                dir('terraform') {
                    script {
                        try {
                            withCredentials([aws(credentialsId: 'aws-config')]) {
                                sh 'terraform fmt'
                            }
                        } catch (err) {
                            echo "Error during Terraform formatting: ${err.message}"
                            currentBuild.result = 'FAILURE'
                            error "Stopping pipeline due to Terraform formatting error."
                        }
                    }
                }
            }
        }
        stage('Validate terraform code') {
            when {
                expression { params.ACTION == 'deploy' }
            }
            steps {
                dir('terraform') {
                    script {
                        try {
                            withCredentials([aws(credentialsId: 'aws-config')]) {
                                sh 'terraform validate'
                            }
                        } catch (err) {
                            echo "Error during Terraform validation: ${err.message}"
                            currentBuild.result = 'FAILURE'
                            error "Stopping pipeline due to Terraform validation error."
                        }
                    }
                }
            }
        }
        
        stage('Plan terraform') {
            steps {
                dir('terraform') {
                    script {
                        try {
                            withCredentials([aws(credentialsId: 'aws-config')]) {
                                sh 'terraform plan'
                            }
                        } catch (err) {
                            echo "Error during Terraform plan: ${err.message}"
                            currentBuild.result = 'FAILURE'
                            error "Stopping pipeline due to Terraform plan error."
                        }
                    }
                }
            }
        }
        stage('Apply/Destroy changes terraform') {
            steps {
                dir('terraform') {
                    script {
                        try {
                            withCredentials([aws(credentialsId: 'aws-config')]) {
                                if (params.ACTION == 'deploy') {
                                    sh 'terraform apply -auto-approve'
                                } else if (params.ACTION == 'destroy') {
                                    sh 'terraform destroy -auto-approve'
                                } else {
                                    error "Invalid action specified: ${params.ACTION}. Supported actions are 'deploy' and 'destroy'."
                                }
                            }
                        } catch (err) {
                            def actionText = params.ACTION == 'destroy' ? 'Destroy' : 'Apply'
                            echo "Error during Terraform ${actionText}: ${err.message}"
                            currentBuild.result = 'FAILURE'
                            error "Stopping pipeline due to Terraform ${actionText.toLowerCase()} error."
                        }
                    }
                }
            }
        }
        
        stage('Deploy to EKS Cluster Region 1') {
            when {
                expression { params.ACTION == 'deploy' }
            }
            steps {
                script {
                    try {
                        withCredentials([aws(credentialsId: 'aws-config', accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY', region: env.AWS_REGION1)]) {
                            sh "aws eks --region ${env.AWS_REGION1} update-kubeconfig --name ${env.AWS_EKS_CLUSTER_NAME_REGION1}"
							
							sh "kubectl config use-context ${env.KUBECONFIG1}"
                                
                                
							sh "helm upgrade --install ${env.HELM_RELEASE_COMPILER_NAME} ${env.HELM_CHART_COMPILER_PATH} --kube-context ${env.KUBECONFIG1}"
							
							if (params.DEPLOY_COMPONENT == 'backend') {
								sh "helm upgrade --install --set backend.tag=${params.COMPONENT_TAG} ${env.HELM_RELEASE_BE_NAME} ${env.HELM_CHART_BE_PATH} --kube-context ${env.KUBECONFIG1}"                                    
							} else if (params.DEPLOY_COMPONENT == 'frontend') {
								sh "helm upgrade --install --set frontend.tag=${params.COMPONENT_TAG} ${env.HELM_RELEASE_FE_NAME} ${env.HELM_CHART_FE_PATH} --kube-context ${env.KUBECONFIG1}"                                    
							} else if (params.DEPLOY_COMPONENT == 'landing') {
								sh "helm upgrade --install --set landing.tag=${params.COMPONENT_TAG} ${env.HELM_RELEASE_UI_NAME} ${env.HELM_CHART_UI_PATH} --kube-context ${env.KUBECONFIG1}"
							} else {
								error "Invalid component specified for deployment: ${params.DEPLOY_COMPONENT}"
							}
                            
                        }
                    } catch (err) {
                        echo "Error during EKS update and deployment in Region 1: ${err.message}"
                        currentBuild.result = 'FAILURE'
                        error "Stopping pipeline due to EKS update and deployment error in Region 1."
                    }
                }
            }
        }
        stage('Deploy to EKS Cluster Region 2') {
            when {
                expression { params.ACTION == 'deploy' }
            }
            steps {
                script {
                    try {
                        withCredentials([aws(credentialsId: 'aws-config', accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY', region: env.AWS_REGION2)]) {
                            sh "aws eks --region ${env.AWS_REGION2} update-kubeconfig --name ${env.AWS_EKS_CLUSTER_NAME_REGION2}"
							sh "kubectl config use-context ${env.KUBECONFIG2}"
							
							sh "helm upgrade --install ${env.HELM_RELEASE_COMPILER_NAME} ${env.HELM_CHART_COMPILER_PATH} --kube-context ${env.KUBECONFIG2}"
							
							if (params.DEPLOY_COMPONENT == 'backend') {
								sh "helm upgrade --install --set backend.tag=${params.COMPONENT_TAG} ${env.HELM_RELEASE_BE_NAME} ${env.HELM_CHART_BE_PATH} --kube-context ${env.KUBECONFIG2}"                                    
							} else if (params.DEPLOY_COMPONENT == 'frontend') {
								sh "helm upgrade --install --set frontend.tag=${params.COMPONENT_TAG} ${env.HELM_RELEASE_FE_NAME} ${env.HELM_CHART_FE_PATH} --kube-context ${env.KUBECONFIG2}"
							} else if (params.DEPLOY_COMPONENT == 'landing') {
								sh "helm upgrade --install --set landing.tag=${params.COMPONENT_TAG} ${env.HELM_RELEASE_UI_NAME} ${env.HELM_CHART_UI_PATH} --kube-context ${env.KUBECONFIG2}"
							} else {
								error "Invalid component specified for deployment: ${params.DEPLOY_COMPONENT}"
							}
                            
                        }
                    } catch (err) {
                        echo "Error during EKS update and deployment in Region 2: ${err.message}"
                        currentBuild.result = 'FAILURE'
                        error "Stopping pipeline due to EKS update and deployment error in Region 2."
                    }
                }
            }
        }
    }
    post {
        always {
            script {
                archiveArtifacts artifacts: '**/*.log', allowEmptyArchive: true
                echo "Cleaning up workspace"
                cleanWs()
            }
        }
        failure {
            script {
                echo "Pipeline failed. Sending notifications..."
                slackSend (
                    channel: '#lms-sparrow-coding-lab',
                    color: COLOR_MAP[currentBuild.currentResult],
                    message: "*${currentBuild.currentResult}:* Job ${env.JOB_NAME} \n build ${env.BUILD_NUMBER} \n More info at: ${env.BUILD_URL}"
                )
            }
        }
        success {
            script {
                echo "Pipeline completed successfully!"
                slackSend (
                    channel: '#lms-sparrow-coding-lab',
                    color: COLOR_MAP[currentBuild.currentResult],
                    message: "*${currentBuild.currentResult}:* Job ${env.JOB_NAME} \n build ${env.BUILD_NUMBER} \n More info at: ${env.BUILD_URL}"
                )
            }
        }        
    }
}