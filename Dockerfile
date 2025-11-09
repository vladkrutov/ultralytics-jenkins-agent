FROM ultralytics/ultralytics:latest

USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      openjdk-17-jre-headless \
      tini \
      curl \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
           /usr/share/doc/* /usr/share/man/*

ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000

# Директория для агента и работы джоб
RUN groupadd -g ${gid} ${group} && \
    useradd -d /home/${user} -u ${uid} -g ${gid} -m -s /bin/bash ${user} && \
    mkdir -p /home/${user}/agent && \  
    mkdir -p /home/${user}/agent/Ultralytics && \ 
    mkdir -p /home/${user}/agent/Ultralytics/runs && \ 
    mkdir -p /home/${user}/agent/Ultralytics/datasets && \ 
    chown -R ${user}:${group} /home/${user} 

# Скрипт запуска агента
COPY jenkins-agent /usr/local/bin/jenkins-agent
RUN chmod +x /usr/local/bin/jenkins-agent

USER ${user}
WORKDIR /home/${user}/agent
RUN yolo settings \
    datasets_dir=/home/${user}/agent/Ultralytics/datasets \
    runs_dir=/home/${user}/agent/Ultralytics/runs

ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/jenkins-agent"]
