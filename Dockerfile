FROM ubuntu 
USER root

RUN echo "Installing Dependancies"  \
 && apt-get update && apt-get install -y openjdk-8-jdk curl wget ca-certificates openssl unzip 

CMD ["gradle"]

ENV GRADLE_HOME /opt/gradle
ENV GRADLE_VERSION 4.7
ENV GRADLE_DOWNLOAD_SHA256 fca5087dc8b50c64655c000989635664a73b11b9bd3703c7d6cabd31b7dcdb04

WORKDIR ${GRADLE_HOME}

RUN echo "Downloading Gradle" \
	&& wget -O gradle.zip "https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip" \
	\
	&& echo "Checking download hash" \
	&& echo "${GRADLE_DOWNLOAD_SHA256} *gradle.zip" | sha256sum -c - \
	\
	&& echo "Installing Gradle" \
	&& unzip gradle.zip \
	&& rm gradle.zip \
	&& mkdir -p ${GRADLE_HOME} \
	&& ln -s "${GRADLE_HOME}/gradle-${GRADLE_VERSION}/bin/gradle" /usr/bin/gradle \
	&& echo "Adding gradle user and group" \
	&& adduser --uid 1000 --home /home/gradle --shell /bin/bash gradle \
	&& mkdir /home/gradle/.gradle \
	&& chown -R gradle:gradle /home/gradle \
	\
	&& echo "Symlinking root Gradle cache to gradle Gradle cache" \
	&& ln -s /home/gradle/.gradle /root/.gradle

# Create Gradle volume
USER gradle
RUN export JAVA_HOME=/usr
VOLUME "/home/gradle/.gradle"
WORKDIR /home/gradle

RUN set -o errexit -o nounset \
	&& echo "Testing Gradle installation" \
	&& gradle --version

USER root

RUN mkdir -p /tmp/download && \
 curl -L https://download.docker.com/linux/static/stable/x86_64/docker-18.03.1-ce.tgz | tar -xz -C /tmp/download && \
 rm -rf /tmp/download/docker/dockerd && \
 mv /tmp/download/docker/docker* /usr/local/bin/ && \
 rm -rf /tmp/download && \
 groupadd -g 999 docker && \
 usermod -aG staff,docker gradle && \
 curl -L https://github.com/docker/compose/releases/download/1.21.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose && \
 chmod +x /usr/local/bin/docker-compose

