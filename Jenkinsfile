// Question 5 - Jenkins pipeline for the automated scripts.
//
// NOTE on the snippet in the assignment: it declares `stages { ... }` three times.
// A declarative pipeline allows ONE `stages` block holding many `stage` blocks, so
// the snippet as printed does not compile ("Multiple occurrences of the stages
// section"). The three stages it asks for are kept exactly, inside one stages block.
pipeline {
    agent any

    parameters {
        choice(name: 'ENV',    choices: ['PUBLIC'],                        description: 'env_config.py environment')
        choice(name: 'SUITES', choices: ['offline', 'web', 'api', 'all'],  description: 'which suites to run')
        string(name: 'BRANCH', defaultValue: 'main',                       description: 'git branch to test')
    }

    environment {
        PROJECT       = 'CI_TTB_ASSIGNMENT'
        RESULT_DIR    = "Results/Jenkins_${env.BUILD_NUMBER}"
        PYTHONIOENCODING = 'utf-8'
        // Playwright needs a writable browser cache on the agent
        PLAYWRIGHT_BROWSERS_PATH = "${env.WORKSPACE}/.pw-browsers"
    }

    options {
        timestamps()
        timeout(time: 30, unit: 'MINUTES')
        buildDiscarder(logRotator(numToKeepStr: '30'))
    }

    stages {
        stage('Checkout Code From Git') {
            steps {
                checkout scmGit(
                    branches: [[name: "*/${params.BRANCH}"]],
                    userRemoteConfigs: [[url: 'https://github.com/<your-account>/CI_TTB_ASSIGNMENT.git']]
                )
                sh 'git --no-pager log -1 --oneline'
            }
        }

        stage('Install Dependencies') {
            steps {
                sh '''
                    python3 -m venv .venv
                    . .venv/bin/activate
                    pip install --quiet --upgrade pip
                    pip install --quiet -r Resources/Launcher/requirements.txt
                    rfbrowser init --skip-browsers || rfbrowser init
                '''
            }
        }

        stage('Run Test Automate') {
            steps {
                script {
                    // tag -> which suites. Mobile (Q4) needs an emulator, so it is not
                    // part of the default CI run.
                    def include = [
                        'offline': '--include offline',
                        'web'    : '--include Q2',
                        'api'    : '--include Q3',
                        'all'    : '--exclude Q4'
                    ][params.SUITES]

                    sh """
                        . .venv/bin/activate
                        robot -v ENV:${params.ENV} ${include} \\
                              -d ${env.RESULT_DIR} \\
                              -N "${env.PROJECT} #${env.BUILD_NUMBER}" \\
                              --xunit xunit.xml \\
                              --output output.xml \\
                              Testcase/
                    """
                }
            }
        }

        stage('Send Result To Jenkins') {
            steps {
                // Robot Framework plugin: the pass/fail trend graph on the job page
                robot(
                    outputPath        : "${env.RESULT_DIR}",
                    outputFileName    : 'output.xml',
                    reportFileName    : 'report.html',
                    logFileName       : 'log.html',
                    passThreshold     : 100.0,
                    unstableThreshold : 90.0,
                    onlyCritical      : false
                )
                junit testResults: "${env.RESULT_DIR}/xunit.xml", allowEmptyResults: true
                archiveArtifacts artifacts: "${env.RESULT_DIR}/**", fingerprint: true, allowEmptyArchive: true
                publishHTML(target: [
                    reportDir            : "${env.RESULT_DIR}",
                    reportFiles          : 'report.html',
                    reportName           : 'Robot Report',
                    keepAll              : true,
                    alwaysLinkToLastBuild: true,
                    allowMissing         : true
                ])
            }
        }
    }

    post {
        always {
            echo "Result: ${currentBuild.currentResult} - see the Robot Report on the build page"
        }
        cleanup {
            sh 'rm -rf .venv'
        }
    }
}
