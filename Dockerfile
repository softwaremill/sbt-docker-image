ARG BASE_IMAGE
FROM openjdk:$BASE_IMAGE

ARG SCALA_VERSION 
ARG SBT_VERSION 

# Install Scala
RUN \
  curl -fsL https://downloads.typesafe.com/scala/$SCALA_VERSION/scala-$SCALA_VERSION.tgz | tar xfz - -C /root/ && \
  echo >> /root/.bashrc && \
  echo 'export PATH=~/scala-$SCALA_VERSION/bin:$PATH' >> /root/.bashrc

# Install sbt
RUN \
  curl -L -o sbt-$SBT_VERSION.deb https://dl.bintray.com/sbt/debian/sbt-$SBT_VERSION.deb && \
  dpkg -i sbt-$SBT_VERSION.deb && \
  rm sbt-$SBT_VERSION.deb && \
  apt-get update && \
  apt-get install sbt && \
  rm -rf /var/lib/apt/lists/*

# Install docker binary
ARG DOCKER_CHANNEL=stable
ARG DOCKER_VERSION=18.06.3-ce
RUN curl -fsSL "https://download.docker.com/linux/static/${DOCKER_CHANNEL}/x86_64/docker-${DOCKER_VERSION}.tgz" \
  | tar -xzC /usr/local/bin --strip=1 docker/docker

# Install GCR credentials helper
ARG GCR_HELPER_VERSION=1.5.0
RUN \
    curl -fsSL https://github.com/GoogleCloudPlatform/docker-credential-gcr/releases/download/v${GCR_HELPER_VERSION}/docker-credential-gcr_linux_amd64-1.5.0.tar.gz \
    | tar -xzC /usr/local/bin && \
    chown root:root /usr/local/bin/docker-credential-gcr && \
    chmod 755 /usr/local/bin/docker-credential-gcr

# Install chrome
RUN \
    apt-get update && \
    apt-get install -y sudo make clang xvfb libxss1 libappindicator1 libindicator7 zlib1g-dev libidn11-dev
RUN \
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    apt install -y ./google-chrome*.deb && \
    rm -rf /var/lib/apt/lists/*
RUN \
    wget https://chromedriver.storage.googleapis.com/2.38/chromedriver_linux64.zip && \
    mkdir -p /opt/chromedriver && \
    unzip chromedriver_linux64.zip -d /opt/chromedriver/ && \
    rm -rf chromedriver_linux64.zip

# Install node
RUN \
    curl -sL https://deb.nodesource.com/setup_10.x -o nodesource_setup.sh && \
    bash nodesource_setup.sh && \
    apt install -y nodejs && \
    rm -rf /var/lib/apt/lists/*


# Add jenkins user
RUN useradd -u 1000 -d /home/jenkins -m jenkins
USER jenkins
WORKDIR /home/jenkins


