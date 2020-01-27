pipeline {
    agent { node { label 'jenkins-worker-1' } }

    options {
        buildDiscarder(logRotator(artifactDaysToKeepStr: '', artifactNumToKeepStr: '', daysToKeepStr: '', numToKeepStr: '10'))

    }

    environment {
        DISTRO = 'jessie'
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
                withCredentials([usernamePassword(credentialsId: 'sonicdev-cr', usernameVariable: 'REGISTRY_USERNAME', passwordVariable: 'REGISTRY_PASSWD')]) {
                    sh './scripts/bldenv/sonic-slave/build.sh'
                }
            }
        }
    }

    post {

        success {
            archiveArtifacts(artifacts: 'sonic-buildimage/target/*.gz')
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
