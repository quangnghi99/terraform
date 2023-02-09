pipeline {
  agent any

  tools {
    terraform 'terraform'
  }

  environment {
    AWS_ACCESS_KEY_ID     = credentials('aws_access_key_id')
    AWS_SECRET_ACCESS_KEY = credentials('aws_secret_access_key')
  }
    parameters{
        choice(
            choices:['apply','destroy'],
            name:'Actions',
            description: 'Describes the Actions')
    }

  stages {
    // Init
    stage('Init Provider') {
      steps {
        sh 'terraform init'
      }
    }

    // stage('Plan Resources') {
    //   steps {
    //     sh 'terraform plan'
    //   }
    // }

    // Action
    stage('Action'){
            steps{
                sh"terraform ${params.Actions} -auto-approve"
            }
        }


    // Complete
    stage('Terraform Completed'){
      steps{
        echo "Terraform Done!"
      }
    }
  }
}

