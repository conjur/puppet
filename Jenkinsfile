#!/usr/bin/env groovy

pipeline {
  agent { label 'executor-v2' }

  options {
    timestamps()
  }

  triggers {
    cron(getDailyCronString())
  }

  stages {
    stage('Validate') {
      parallel {
        stage('Changelog') {
          steps { sh './parse-changelog.sh' }
        }
      }
    }

    // workaround for Jenkins not fetching tags
    stage('Fetch tags') {
      steps {
        withCredentials(
          [usernameColonPassword(credentialsId: 'conjur-jenkins-api', variable: 'GITCREDS')]
        ) {
          sh '''
            git fetch --tags `git remote get-url origin | sed -e "s|https://|https://$GITCREDS@|"`
            git tag # just print them out to make sure, can remove when this is robust
          '''
        }
      }
    }

    stage('Build') {
      steps {
        sh './build.sh'
        archiveArtifacts 'pkg/'
      }
    }


    stage('Tests') {
      parallel {
        stage('Linting and unit tests') {
          steps {
            sh './test.sh'
          }

          post {
            always {
              junit 'spec/output/rspec.xml'
              cobertura autoUpdateHealth: true, autoUpdateStability: true, coberturaReportFile: 'coverage/coverage.xml', conditionalCoverageTargets: '100, 0, 0', failUnhealthy: true, failUnstable: false, lineCoverageTargets: '99, 0, 0', maxNumberOfBuilds: 0, methodCoverageTargets: '100, 0, 0', onlyStable: false, sourceEncoding: 'ASCII', zoomCoverageChart: false
              archiveArtifacts artifacts: 'spec/output/rspec.xml', fingerprint: true
            }
          }
        }

        stage('E2E - Puppet 6 - Conjur 5') {
          steps {
            dir('examples/puppetmaster') {
              sh './test.sh'
            }
          }
        }
      }
    }

    stage('Release Puppet module') {
      when {
        allOf {
          // Current git HEAD is an annotated tag
          expression {
            sh(returnStatus: true, script: 'git describe --exact | grep -q \'^v[0-9.]\\+$\'') == 0
          }
          not { triggeredBy  'TimerTrigger' }
        }
      }
      steps {
        sh './release.sh'
      }
    }
  }

  post {
    always {
      cleanupAndNotify(currentBuild.currentResult)
    }
  }
}
