pipeline {
    agent { node { label 'jenkins-workers-slow' } }

    options {
        buildDiscarder(logRotator(artifactDaysToKeepStr: '', artifactNumToKeepStr: '', daysToKeepStr: '', numToKeepStr: '30'))

    }

    environment {
        DOCKER_IMAGE_FILE = 'docker-sonic-mgmt.gz'
        DOCKER_IMAGE_TAG  = 'latest'
    }

    triggers {
        pollSCM('@midnight')
    }

    stages {
        stage('Prepare') {
            steps {
                dir('sonic-buildimage') {
                    checkout([$class: 'GitSCM',
                              branches: [[name: '*/master']],
                              extensions: [[$class: 'SubmoduleOption',
                                            disableSubmodules: false,
                                            recursiveSubmodules: true]],
                              userRemoteConfigs: [[url: 'https://github.com/Azure/sonic-buildimage']]])
                }
            }
        }

        stage('Build') {
            steps {
                sh '''
#!/bin/bash -xe

cd sonic-buildimage
git submodule foreach --recursive '[ -f .git ] && echo "gitdir: $(realpath --relative-to=. $(cut -d" " -f2 .git))" > .git'

make configure PLATFORM=generic
make SONIC_CONFIG_BUILD_JOBS=1 target/docker-sonic-mgmt.gz
'''
            }
        }

        stage('Upload') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'sonicdev-cr', usernameVariable: 'REGISTRY_USERNAME', passwordVariable: 'REGISTRY_PASSWD')]) {
                    sh './scripts/lib/docker-upload.sh'
                }
            }
        }
    }

    post {

        success {
            archiveArtifacts(artifacts: 'target/docker-sonic-mgmt.gz')
        }
        fixed {
            slackSend(color:'#00FF00', message: "Build job back to normal: ${env.JOB_NAME} ${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>)")
        }
        regression {
            slackSend(color:'#FF0000', message: "Build job Regression: ${env.JOB_NAME} ${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>)")
        }
        cleanup {
            cleanWs(disableDeferredWipeout: false, deleteDirs: true, notFailBuild: true)
        }
    }
}
