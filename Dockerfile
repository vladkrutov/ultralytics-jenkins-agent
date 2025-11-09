FROM ultralytics/ultralytics:latest

USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      openjdk-17-jre-headless \
      tini \
      curl \
    && rm -rf /var/lib/apt/lists/*

ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000

RUN groupadd -g ${gid} ${group} && \
    useradd -d /home/${user} -u ${uid} -g ${gid} -m -s /bin/bash ${user}

# Директория для агента и работы джоб
RUN mkdir -p /home/${user}/work && chown -R ${user}:${group} /home/${user}

# Скрипт запуска агента
COPY jenkins-agent /usr/local/bin/jenkins-agent
RUN chmod +x /usr/local/bin/jenkins-agent

USER ${user}
WORKDIR /home/${user}/work

ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/jenkins-agent"]