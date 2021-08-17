pipeline {
    agent any
    stages {
        stage("Packer build") {
            agent {
                label "macos"
            }
            steps {
                sh '''#!/bin/bash -l
                    eval "$(docker-machine env default)"
                    cd /Users/jenkins/packer-terraform/packer
                    if ! [[ -f "$FILE" ]]; then
                        touch apache.md5;
                    fi
                    md5checksum=$(md5 -q apache.pkr.hcl)
                    if ! grep -q $md5checksum apache.md5; then
                        packer build .
                        md5 -q apache.pkr.hcl > apache.md5
                    fi
                '''
            }
        }
        stage("Terraform apply") {
            agent {
                label "macos"
            }
            steps {
                sh '''#!/bin/bash -l
                    cd /Users/jenkins/packer-terraform/terraform
                    terraform apply -auto-approve
                '''
            }
        }
    }
}
