def label = "${UUID.randomUUID().toString()}"
def baseImageTag = "11.0.11-jdk"
def scalaVersion = "2.13.3"
def sbtVersion = "1.4.9"
def dockerRepo = "softwaremill/sbt-jenkins"

podTemplate(label: label, yaml: """
kind: Pod
metadata:
  name: kaniko
spec:
  containers:
  - name: kaniko
    image: gcr.io/kaniko-project/executor:debug
    imagePullPolicy: Always
    command:
    - /busybox/cat
    tty: true
    volumeMounts:
      - name: docker-config-json
        mountPath: /kaniko/.docker
  volumes:
  - name: docker-config-json
    projected:
      sources:
      - secret:
          name: sml-docker-cred
          items:
            - key: .dockerconfigjson
              path: config.json
"""
) {

    node(label) {
        try {
            ansiColor('xterm') {
                stage('Checkout') {
                    checkout scm
                }
                container(name: 'kaniko', shell: '/busybox/sh') {
                    stage('Build') {
                        withEnv(['PATH+EXTRA=/busybox:/kaniko']) {
                            sh """#!/busybox/sh
                        /kaniko/executor -f `pwd`/Dockerfile \\
                            -c `pwd` \\
                            --build-arg BASE_IMAGE=$baseImageTag \\
                            --build-arg SCALA_VERSION=$scalaVersion \\
                            --build-arg SBT_VERSION=$sbtVersion \\
                            --destination $dockerRepo:${baseImageTag}_${scalaVersion}_${sbtVersion}
                        """
                        }
                    }
                }
            }
        } catch (e) {
            currentBuild.result = 'FAILED'
            throw e
        }
        stage('Build with Kaniko') {
            git 'https://github.com/jenkinsci/docker-jnlp-slave.git'
            container(name: 'kaniko', shell: '/busybox/sh') {

            }
        }
    }
}
