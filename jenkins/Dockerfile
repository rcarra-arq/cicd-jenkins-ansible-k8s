FROM jenkins/jenkins:lts-jdk17

USER root

# Docker CLI (só o cliente — o daemon roda na VM, via socket montado)
RUN apt-get update && \
    apt-get install -y ca-certificates curl gnupg && \
    install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/debian/gpg \
      | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
      https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
      > /etc/apt/sources.list.d/docker.list && \
    apt-get update && \
    apt-get install -y docker-ce-cli && \
    rm -rf /var/lib/apt/lists/*

# kubectl
RUN curl -fsSL "https://dl.k8s.io/release/$(curl -fsSL https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
      -o /usr/local/bin/kubectl && \
    chmod +x /usr/local/bin/kubectl

# kind
RUN curl -fsSL "https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64" \
      -o /usr/local/bin/kind && \
    chmod +x /usr/local/bin/kind

# Ansible
RUN apt-get update && \
    apt-get install -y python3-pip && \
    pip3 install --break-system-packages ansible && \
    rm -rf /var/lib/apt/lists/*

USER jenkins
