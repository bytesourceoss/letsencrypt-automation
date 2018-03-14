pipeline {
  agent { label 'master' }

  options {
    buildDiscarder(logRotator(numToKeepStr:'20'))
    disableConcurrentBuilds()
    timeout(time: 30, unit: 'MINUTES')
  }
  triggers {
    // pollSCM('H/4 * * * *')
  }

  // parameters {
  //   string(name: 'workspaces', defaultValue: '', description: 'The workspaces separated by a space to check, plan and apply.')
  // }

  stages {
    stage('Init') {
      steps {
        script  {
          ansiColor('xterm') {
            sh("rake23 init")
          }
        }
      }
    }

    stage('Certbot') {
      steps {
        script {
          try {
            ansiColor('xterm') {
              sh("rake23 certbot:renew")
            }
          } catch(err) {
            currentBuild.result = 'UNSTABLE'
          }
        }
      }
    }

    stage('Chef Vault') {
      steps {
        ansiColor('xterm') {
          sh("rake23 chef_vault:upload")
        }
      }
    }

    stage('Hashicorp Vault') {
      // when {
      //   allOf {
      //     branch 'master'
      //     expression { return resultSuccess() }
      //   }
      // }
      steps {
        ansiColor('xterm') {
          sh("rake23 hashicorp_vault:upload")
        }
      }
    }

    stage('Git push') {
      steps {
        ansiColor('xterm') {
          sh("rake23 git:push")
        }
      }
    }

    stage('Cleanup') {
      // when {
      //   allOf {
      //     branch 'master'
      //     expression { return resultSuccess() }
      //     expression { return approved }
      //   }
      // }
      steps {
        script {
          ansiColor('xterm') {
            sh("rake23 cleanup")
          }
        }
      }
    }
  }
}
