# Cloud environment container
# Provides a suite of cloud tools for AWS, GCP and Kubernetes

FROM alpine:3.13.5

WORKDIR /usr/bin/

# Install base deps and pip modules
RUN apk --update --no-cache upgrade -a \
  && apk --update --no-cache add \
    bash \
    bash-completion \
    bind-tools \
    ca-certificates \
    coreutils \
    curl \
    diffutils \
    fish \
    fzf \
    fzf-bash-completion \
    git \
    gnupg \
    groff \
    iputils \
    jq \
    keychain \
    libusb \
    ncurses \
    net-tools \
    nmap \
    openssh-client \
    openssl \
    perl \
    py3-pip \
    python3 \
    shadow \
    su-exec \
    tmux \
    tzdata \
  && pip install --upgrade pip \
  && pip install --no-cache-dir  \
    aws-export-credentials \
    cookiecutter \
    datadog \
    okta-awscli \
    wheel \
  && curl -o /usr/local/bin/ecs-cli https://s3.amazonaws.com/amazon-ecs-cli/ecs-cli-linux-amd64-latest \
  && chmod +x /usr/local/bin/ecs-cli \
  && sed -i 's/^CREATE_MAIL_SPOOL=yes/CREATE_MAIL_SPOOL=no/' /etc/default/useradd \
  && mkdir -p /etc/bash_completion.d \
  && ln -s /usr/bin/python3 /usr/bin/python

# Install software / modules that need build_base
RUN apk --update --no-cache add --virtual build.deps \
    build-base \
    cargo \
    libffi-dev \
    openssl-dev \
    python3-dev \
    rust \
  && pip install --no-cache-dir \
    aws-okta-keyman \
    aws-sam-cli \
    ec2instanceconnectcli \
    keyrings.cryptfile \
  && apk del build.deps


# Install glibc
ENV GLIBC_VERSION 2.33-r0
ENV GLIBC_URL https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}
ENV GLIBC_FILENAME glibc-${GLIBC_VERSION}.apk
ENV GLIBC_SHA256 3ce2b708b17841bc5978da0fa337fcb90fec5907daa396585db68805754322e0

RUN wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
  && wget $GLIBC_URL/$GLIBC_FILENAME \
  && wget $GLIBC_URL/glibc-bin-${GLIBC_VERSION}.apk \
  && echo "$GLIBC_SHA256  ./$GLIBC_FILENAME" | sha256sum -c - \
  && apk add --no-cache ./$GLIBC_FILENAME ./glibc-bin-${GLIBC_VERSION}.apk \
  && rm -f ./$GLIBC_FILENAME \
  && rm -f glibc-bin-${GLIBC_VERSION}.apk


# Install KUBECTL
# From https://storage.googleapis.com/kubernetes-release/release/stable.txt
# curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
ENV KUBECTL_VERSION 1.21.1
ENV KUBECTL_URL https://storage.googleapis.com/kubernetes-release/release/v$KUBECTL_VERSION/bin/linux/amd64
ENV KUBECTL_FILENAME kubectl
ENV KUBECTL_SHA256 58785190e2b4fc6891e01108e41f9ba5db26e04cebb7c1ac639919a931ce9233

RUN wget $KUBECTL_URL/$KUBECTL_FILENAME \
  && echo "$KUBECTL_SHA256  ./$KUBECTL_FILENAME" | sha256sum -c - \
  && chmod +x ./$KUBECTL_FILENAME \
  && kubectl completion bash > /etc/bash_completion.d/kubectl


# Install HELM
# From https://github.com/helm/helm/releases
ENV HELM_VERSION 3.6.0
ENV HELM_URL https://get.helm.sh
ENV HELM_FILENAME helm-v${HELM_VERSION}-linux-amd64.tar.gz
ENV HELM_SHA256 0a9c80b0f211791d6a9d36022abd0d6fd125139abe6d1dcf4c5bf3bc9dcec9c8

RUN wget $HELM_URL/$HELM_FILENAME \
  && echo "$HELM_SHA256  ./$HELM_FILENAME" | sha256sum -c - \
  && tar -xzf $HELM_FILENAME \
  && mv ./linux-amd64/helm ./ \
  && rm -rf ./linux-amd64 \
  && rm -f $HELM_FILENAME \
  && chmod +x ./helm \
  && helm completion bash > /etc/bash_completion.d/helm


# Install terraform 11
# From https://www.terraform.io/downloads.html
ENV TERRAFORM_11_VERSION 0.11.15
ENV TERRAFORM_11_URL https://releases.hashicorp.com/terraform/$TERRAFORM_11_VERSION
ENV TERRAFORM_11_FILENAME terraform_${TERRAFORM_11_VERSION}_linux_amd64.zip
ENV TERRAFORM_11_SHA256 e6c8c884de6c353cf98252c5e11faf972d4b30b5d070ab5ff70eaf92660a5aac

RUN wget $TERRAFORM_11_URL/$TERRAFORM_11_FILENAME \
  && echo "$TERRAFORM_11_SHA256  ./$TERRAFORM_11_FILENAME" | sha256sum -c - \
  && unzip ./$TERRAFORM_11_FILENAME \
  && rm ./$TERRAFORM_11_FILENAME \
  && chmod +x ./terraform \
  && mv ./terraform ./terraform11

# Install terraform 12
# From https://www.terraform.io/downloads.html
ENV TERRAFORM_12_VERSION 0.12.31
ENV TERRAFORM_12_URL https://releases.hashicorp.com/terraform/$TERRAFORM_12_VERSION
ENV TERRAFORM_12_FILENAME terraform_${TERRAFORM_12_VERSION}_linux_amd64.zip
ENV TERRAFORM_12_SHA256 e5eeba803bc7d8d0cae7ef04ba7c3541c0abd8f9e934a5e3297bf738b31c5c6d

RUN wget $TERRAFORM_12_URL/$TERRAFORM_12_FILENAME \
  && echo "$TERRAFORM_12_SHA256  ./$TERRAFORM_12_FILENAME" | sha256sum -c - \
  && unzip ./$TERRAFORM_12_FILENAME \
  && rm ./$TERRAFORM_12_FILENAME \
  && chmod +x ./terraform \
  && mv ./terraform ./terraform12

# Install terraform latest
# From https://www.terraform.io/downloads.html
ENV TERRAFORM_LATEST_VERSION 1.0.0
ENV TERRAFORM_LATEST_URL https://releases.hashicorp.com/terraform/$TERRAFORM_LATEST_VERSION
ENV TERRAFORM_LATEST_FILENAME terraform_${TERRAFORM_LATEST_VERSION}_linux_amd64.zip
ENV TERRAFORM_LATEST_SHA256 8be33cc3be8089019d95eb8f546f35d41926e7c1e5deff15792e969dde573eb5

RUN wget $TERRAFORM_LATEST_URL/$TERRAFORM_LATEST_FILENAME \
  && echo "$TERRAFORM_LATEST_SHA256  ./$TERRAFORM_LATEST_FILENAME" | sha256sum -c - \
  && unzip ./$TERRAFORM_LATEST_FILENAME \
  && rm ./$TERRAFORM_LATEST_FILENAME \
  && chmod +x ./terraform \
  && mv ./terraform ./terraform-latest

# Use Terrafrom latest by default
RUN ln -s ./terraform-latest ./terraform


# Install terragrunt 18
# From https://github.com/gruntwork-io/terragrunt/releases
ENV TERRAGRUNT_OLD_VERSION 0.18.7
ENV TERRAGRUNT_OLD_URL https://github.com/gruntwork-io/terragrunt/releases/download/v$TERRAGRUNT_OLD_VERSION
ENV TERRAGRUNT_OLD_FILENAME terragrunt_linux_amd64
ENV TERRAGRUNT_OLD_SHA256 3a45138e77fb41e0884b9491c67dcdeacd06418cd10a1e16ea0cc03976f1b288

RUN wget $TERRAGRUNT_OLD_URL/$TERRAGRUNT_OLD_FILENAME \
  && echo "$TERRAGRUNT_OLD_SHA256  ./$TERRAGRUNT_OLD_FILENAME" | sha256sum -c - \
  && mv ./$TERRAGRUNT_OLD_FILENAME ./terragrunt18 \
  && chmod +x ./terragrunt18

# Install terragrunt 19+
# From https://github.com/gruntwork-io/terragrunt/releases
ENV TERRAGRUNT_NEW_VERSION 0.30.3
ENV TERRAGRUNT_NEW_URL https://github.com/gruntwork-io/terragrunt/releases/download/v$TERRAGRUNT_NEW_VERSION
ENV TERRAGRUNT_NEW_FILENAME terragrunt_linux_amd64
ENV TERRAGRUNT_NEW_SHA256 d6455b79c444b218e2be8349496f7edfdb000e2ed46f978388b46f3438fd6741

RUN wget $TERRAGRUNT_NEW_URL/$TERRAGRUNT_NEW_FILENAME \
  && echo "$TERRAGRUNT_NEW_SHA256  ./$TERRAGRUNT_NEW_FILENAME" | sha256sum -c - \
  && mv ./$TERRAGRUNT_NEW_FILENAME ./terragrunt \
  && chmod +x ./terragrunt


# Install packer
# From https://www.packer.io/downloads.html
ENV PACKER_VERSION 1.7.2
ENV PACKER_URL https://releases.hashicorp.com/packer/$PACKER_VERSION
ENV PACKER_FILENAME packer_${PACKER_VERSION}_linux_amd64.zip
ENV PACKER_SHA256 9429c3a6f80b406dbddb9b30a4e468aeac59ab6ae4d09618c8d70c4f4188442e

RUN wget $PACKER_URL/$PACKER_FILENAME \
  && echo "$PACKER_SHA256  ./$PACKER_FILENAME" | sha256sum -c - \
  && unzip ./$PACKER_FILENAME \
  && rm ./$PACKER_FILENAME \
  && chmod +x ./packer


# Install aws-iam-authenticator
# From https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html
# https://github.com/kubernetes-sigs/aws-iam-authenticator/releases
ENV AWS_IAM_AUTH_VERSION 0.5.3
ENV AWS_IAM_AUTH_URL https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v${AWS_IAM_AUTH_VERSION}
ENV AWS_IAM_AUTH_FILENAME aws-iam-authenticator_${AWS_IAM_AUTH_VERSION}_linux_amd64
ENV AWS_IAM_AUTH_SHA256 20f4d8ece0f867c38b917ebe37dff934a31aabe385e26986183b14d72c70c137

RUN wget $AWS_IAM_AUTH_URL/$AWS_IAM_AUTH_FILENAME \
  && echo "$AWS_IAM_AUTH_SHA256  ./$AWS_IAM_AUTH_FILENAME" | sha256sum -c - \
  && chmod +x ./${AWS_IAM_AUTH_FILENAME} \
  && mv ./${AWS_IAM_AUTH_FILENAME} ./aws-iam-authenticator


# Install Kubectx
# From https://github.com/ahmetb/kubectx/releases
ENV KUBECTX_VERSION 0.9.3
ENV KUBECTX_URL https://github.com/ahmetb/kubectx/archive
ENV KUBECTX_FILENAME v${KUBECTX_VERSION}.tar.gz
ENV KUBECTX_SHA256 c9f1323f759605405ef8240d6fa64e741b788d978dff25d624a90af2760e778d

RUN wget $KUBECTX_URL/$KUBECTX_FILENAME \
  && echo "$KUBECTX_SHA256  ./$KUBECTX_FILENAME" | sha256sum -c - \
  && tar -xzf ./$KUBECTX_FILENAME \
  && rm ./$KUBECTX_FILENAME \
  && cp ./kubectx-${KUBECTX_VERSION}/completion/kubectx.bash /etc/bash_completion.d/kubectx \
  && cp ./kubectx-${KUBECTX_VERSION}/completion/kubens.bash /etc/bash_completion.d/kubens \
  && cp ./kubectx-${KUBECTX_VERSION}/kubectx . \
  && cp ./kubectx-${KUBECTX_VERSION}/kubens . \
  && rm -rf ./kubectx-${KUBECTX_VERSION} \
  && chmod +x ./kubectx \
  && chmod +x ./kubens


# Install Kops
# From https://github.com/kubernetes/kops/releases
ENV KOPS_VERSION 1.20.1
ENV KOPS_URL https://github.com/kubernetes/kops/releases/download/v${KOPS_VERSION}
ENV KOPS_FILENAME kops-linux-amd64
ENV KOPS_SHA256 72acac518ccddfe323ab95b1f59067036fc90eb67b9fb44d899486a5431a2657

RUN wget $KOPS_URL/$KOPS_FILENAME \
  && echo "$KOPS_SHA256  ./$KOPS_FILENAME" | sha256sum -c - \
  && chmod +x ./${KOPS_FILENAME} \
  && mv ./${KOPS_FILENAME} ./kops \
  && kops completion bash > /etc/bash_completion.d/kops


# Install kompose
# From https://github.com/kubernetes/kompose/releases
ENV KOMPOSE_VERSION 1.22.0
ENV KOMPOSE_URL https://github.com/kubernetes/kompose/releases/download/v${KOMPOSE_VERSION}
ENV KOMPOSE_FILENAME kompose-linux-amd64
ENV KOMPOSE_SHA256 6203d67263886bbd455168f59309496d486fc3a6df330b7ba37823b283bd9ea5

RUN wget $KOMPOSE_URL/$KOMPOSE_FILENAME \
  && echo "$KOMPOSE_SHA256  ./$KOMPOSE_FILENAME" | sha256sum -c - \
  && chmod +x ./${KOMPOSE_FILENAME} \
  && mv ./${KOMPOSE_FILENAME} ./kompose \
  && kompose completion bash > /etc/bash_completion.d/kompose


# Install k9s
# From https://github.com/derailed/k9s/releases
ENV K9S_VERSION 0.24.10
ENV K9S_URL https://github.com/derailed/k9s/releases/download/v${K9S_VERSION}
ENV K9S_FILENAME k9s_v${K9S_VERSION}_Linux_x86_64.tar.gz
ENV K9S_SHA256 bf1fbcf145b8e021b675bae009183e7028afbce52fc44c37f6a0dd2982152c21

RUN wget $K9S_URL/$K9S_FILENAME \
  && echo "$K9S_SHA256  ./$K9S_FILENAME" | sha256sum -c - \
  && tar -xzf ./${K9S_FILENAME} \
  && chmod +x ./k9s \
  && rm -f LICENSE \
  && rm -f README.md \
  && rm -f ./${K9S_FILENAME}


# Install fluxctl
# From https://github.com/fluxcd/flux/releases
ENV FLUXCTL_VERSION 1.22.2
ENV FLUXCTL_URL https://github.com/fluxcd/flux/releases/download/${FLUXCTL_VERSION}
ENV FLUXCTL_FILENAME fluxctl_linux_amd64
ENV FLUXCTL_SHA256 cdd2f74dc247a925914d37e48967c9f81afb03a876e2416084a695a8ee8ccbd3

RUN wget $FLUXCTL_URL/$FLUXCTL_FILENAME \
  && echo "$FLUXCTL_SHA256  ./$FLUXCTL_FILENAME" | sha256sum -c - \
  && chmod +x ./${FLUXCTL_FILENAME} \
  && mv ./${FLUXCTL_FILENAME} ./fluxctl


# Install rakkess
# From https://github.com/corneliusweig/rakkess/releases
ENV RAKKESS_VERSION 0.4.7
ENV RAKKESS_URL https://github.com/corneliusweig/rakkess/releases/download/v${RAKKESS_VERSION}
ENV RAKKESS_FILENAME rakkess-amd64-linux.tar.gz
ENV RAKKESS_SHA256 f4b175d0a8ed20c98949bde23c2b8f7a4479c644a12191959c2e95c3def25f75

RUN wget $RAKKESS_URL/$RAKKESS_FILENAME \
  && echo "$RAKKESS_SHA256  ./$RAKKESS_FILENAME" | sha256sum -c - \
  && tar -xzf ./${RAKKESS_FILENAME} \
  && mv ./rakkess-amd64-linux ./rakkess \
  && chmod +x ./rakkess \
  && rm -f ./${RAKKESS_FILENAME} \
  && rm -f ./LICENSE \
  && rakkess completion bash > /etc/bash_completion.d/rakkess


# Install kubespy
# From https://github.com/pulumi/kubespy/releases
ENV KUBESPY_VERSION 0.4.0
ENV KUBESPY_URL https://github.com/pulumi/kubespy/releases/download/v${KUBESPY_VERSION}
ENV KUBESPY_FILENAME kubespy-linux-amd64.tar.gz
ENV KUBESPY_SHA256 04e3c2d3583e3817e95dfa5041ad97b9fca9d4349f088c3520a233cca16cac55

RUN wget $KUBESPY_URL/$KUBESPY_FILENAME \
  && echo "$KUBESPY_SHA256  ./$KUBESPY_FILENAME" | sha256sum -c - \
  && tar -xzf ./${KUBESPY_FILENAME} \
  && mv ./releases/kubespy-linux-amd64/kubespy ./ \
  && chmod +x ./kubespy \
  && rm -f ./${KUBESPY_FILENAME} \
  && rm -rf ./releases


# Install eksctl
# From https://github.com/weaveworks/eksctl/releases
ENV EKSCTL_VERSION 0.53.0
ENV EKSCTL_URL https://github.com/weaveworks/eksctl/releases/download/${EKSCTL_VERSION}
ENV EKSCTL_FILENAME eksctl_Linux_amd64.tar.gz
ENV EKSCTL_SHA256 61554b58513c5246beec57ad6b80c6636b0afcf15dc66bbb68377bd09966f0f9

RUN wget $EKSCTL_URL/$EKSCTL_FILENAME \
  && echo "$EKSCTL_SHA256  ./$EKSCTL_FILENAME" | sha256sum -c - \
  && tar -xzf ./${EKSCTL_FILENAME} \
  && chmod +x ./eksctl \
  && rm -f ./${EKSCTL_FILENAME} \
  && eksctl completion bash > /etc/bash_completion.d/eksctl


# Install the AWS session manager plugin
ENV AWSSMP_VERSION 1.1.31.0
ENV AWSSMP_URL https://s3.amazonaws.com/session-manager-downloads/plugin/${AWSSMP_VERSION}/linux_64bit
ENV AWSSMP_FILENAME session-manager-plugin.rpm
ENV AWSSMP_SHA256 6a4abafaa921a5ff242bb8dfff18d528f1544e22571ba03b3a5d7d4d3cf28072

RUN apk --update --no-cache add --virtual build.deps \
    rpm2cpio \
  && wget $AWSSMP_URL/$AWSSMP_FILENAME \
  && echo "$AWSSMP_SHA256  ./$AWSSMP_FILENAME" | sha256sum -c - \
  && rpm2cpio ./session-manager-plugin.rpm | cpio -idmv \
  && mv ./usr/local/sessionmanagerplugin/bin/session-manager-plugin /usr/local/bin/ \
  && rm -rf ./etc ./usr ./var ./$AWSSMP_FILENAME \
  && apk del build.deps


# Install cloud-nuke (temp disable upgrading again)
ENV CLOUD_NUKE_UPGRADE false
ENV CLOUD_NUKE_VERSION 0.1.18
ENV CLOUD_NUKE_URL https://github.com/gruntwork-io/cloud-nuke/releases/download/v${CLOUD_NUKE_VERSION}
ENV CLOUD_NUKE_FILENAME cloud-nuke_linux_amd64
ENV CLOUD_NUKE_SHA256 7cf26457baa404017b2e89b6768a1ee24073ec0ca17bcdf23a79efb27f5bb736

RUN wget $CLOUD_NUKE_URL/$CLOUD_NUKE_FILENAME \
  && echo "$CLOUD_NUKE_SHA256  ./$CLOUD_NUKE_FILENAME" | sha256sum -c - \
  && chmod +x ./${CLOUD_NUKE_FILENAME} \
  && mv ./${CLOUD_NUKE_FILENAME} ./cloud-nuke


# Install confd
ENV CONFD_VERSION 0.16.0
ENV CONFD_URL https://github.com/kelseyhightower/confd/releases/download/v$CONFD_VERSION
ENV CONFD_FILENAME confd-$CONFD_VERSION-linux-amd64
ENV CONFD_SHA256 255d2559f3824dd64df059bdc533fd6b697c070db603c76aaf8d1d5e6b0cc334

RUN wget $CONFD_URL/$CONFD_FILENAME \
  && echo "$CONFD_SHA256  ./$CONFD_FILENAME" | sha256sum -c - \
  && mv ./$CONFD_FILENAME /usr/bin/confd \
  && chmod +x /usr/bin/confd \
  && mkdir -p /etc/confd/conf.d \
  && mkdir -p /etc/confd/templates


# Install aws-okta
# Upstream has stopped providing pre-built binaries
ENV AWS_OKTA_VERSION 1.0.11
ENV AWS_OKTA_URL https://github.com/segmentio/aws-okta/archive
ENV AWS_OKTA_FILENAME v${AWS_OKTA_VERSION}.tar.gz
ENV AWS_OKTA_SHA256 444a84cd9c81097a7c462f806605193c5676879133255cfa0f610b7d14756b65

RUN wget $AWS_OKTA_URL/$AWS_OKTA_FILENAME \
  && echo "$AWS_OKTA_SHA256  ./$AWS_OKTA_FILENAME" | sha256sum -c - \
  && tar -xzf ./$AWS_OKTA_FILENAME \
  && apk --update --no-cache add --virtual build.deps \
    go \
  && export CGO_ENABLED=0 \
  && cd ./aws-okta-${AWS_OKTA_VERSION} \
  && go build \
  && cd .. \
  && mv ./aws-okta-${AWS_OKTA_VERSION}/aws-okta /usr/bin/aws-okta \
  && rm -rf ./aws-okta-${AWS_OKTA_VERSION} \
  && rm -rf ./$AWS_OKTA_FILENAME \
  && go clean -cache \
  && apk del build.deps \
  && rm -rf /root/go/ \
  && rm -rf /root/.cache \
  && /usr/bin/aws-okta completion bash > /etc/bash_completion.d/aws-okta


# Install terraform-docs
ENV TERRAFORM_DOCS_VERSION 0.14.1
ENV TERRAFORM_DOCS_URL https://github.com/terraform-docs/terraform-docs/releases/download/v$TERRAFORM_DOCS_VERSION
ENV TERRAFORM_DOCS_FILENAME terraform-docs-v${TERRAFORM_DOCS_VERSION}-linux-amd64.tar.gz
ENV TERRAFORM_DOCS_SHA256 f0a46b13c126f06eba44178f901bb7b6b5f61a8b89e07a88988c6f45e5fcce19

RUN wget $TERRAFORM_DOCS_URL/$TERRAFORM_DOCS_FILENAME \
  && echo "$TERRAFORM_DOCS_SHA256  ./$TERRAFORM_DOCS_FILENAME" | sha256sum -c - \
  && tar -xzf ./$TERRAFORM_DOCS_FILENAME \
  && chmod +x /usr/bin/terraform-docs \
  && /usr/bin/terraform-docs completion bash > /etc/bash_completion.d/terraform-docs \
  && rm -f ./$TERRAFORM_DOCS_FILENAME


# Install aws-connect
ENV AWS_CONNECT_VERSION 1.0.11
ENV AWS_CONNECT_URL https://github.com/rewindio/aws-connect/archive
ENV AWS_CONNECT_FILENAME v${AWS_CONNECT_VERSION}.tar.gz
ENV AWS_CONNECT_SHA256 56d9ae4695302ca93c4020bf634d5f09eb772dfde7be2db02035266b7d3d44a2

RUN wget $AWS_CONNECT_URL/$AWS_CONNECT_FILENAME \
  && echo "$AWS_CONNECT_SHA256  ./$AWS_CONNECT_FILENAME" | sha256sum -c - \
  && tar -xzf ./${AWS_CONNECT_FILENAME} \
  && mv ./aws-connect-${AWS_CONNECT_VERSION}/aws-connect /usr/local/bin/aws-connect \
  && chmod +x /usr/local/bin/aws-connect \
  && rm -f ./${AWS_CONNECT_FILENAME} \
  && rm -rf ./aws-connect-${AWS_CONNECT_VERSION}


# Install AWS CLI v2
ENV AWS_CLI_VERSION 2.2.11
ENV AWS_CLI_URL https://awscli.amazonaws.com
ENV AWS_CLI_FILENAME awscli-exe-linux-x86_64-${AWS_CLI_VERSION}.zip
ENV AWS_CLI_SHA256 06507d385c668a5015b43b8f642c76ca5d865448d9408b509679fc8d5d7d6907

RUN wget $AWS_CLI_URL/$AWS_CLI_FILENAME \
  && echo "$AWS_CLI_SHA256  ./$AWS_CLI_FILENAME" | sha256sum -c - \
  && unzip ./$AWS_CLI_FILENAME \
  && rm -f ./$AWS_CLI_FILENAME \
  && ./aws/install \
  && rm -rf ./aws


WORKDIR /opt

# Install gcloud suite
# From https://cloud.google.com/sdk/docs/quickstart-linux
ENV GCLOUD_VERSION 344.0.0
ENV GCLOUD_URL https://dl.google.com/dl/cloudsdk/channels/rapid/downloads
ENV GCLOUD_FILENAME google-cloud-sdk-${GCLOUD_VERSION}-linux-x86_64.tar.gz
ENV GCLOUD_SHA256 52bcdb2ab766587f510c08d4f55dd239c2eb6a900ab31ee8683624e42f2372b6

RUN wget $GCLOUD_URL/$GCLOUD_FILENAME \
  && echo "$GCLOUD_SHA256  ./$GCLOUD_FILENAME" | sha256sum -c - \
  && tar -xzf ./$GCLOUD_FILENAME \
  && rm ./$GCLOUD_FILENAME \
  && ./google-cloud-sdk/install.sh --quiet


COPY docker-entrypoint.sh /docker-entrypoint.sh
COPY clearokta /usr/bin/clearokta

# Set up bashrc and scripts
RUN echo "# Added at containter build-time" >> /etc/ssh/ssh_config \
  && echo "    Host *" >> /etc/ssh/ssh_config \
  && echo "ServerAliveInterval 30" >> /etc/ssh/ssh_config \
  && echo "ServerAliveCountMax 3" >> /etc/ssh/ssh_config \
  && chmod +x /docker-entrypoint.sh \
  && chmod +x /usr/bin/clearokta

RUN echo "Test Layer" \
  && /opt/google-cloud-sdk/bin/gcloud version \
  && aws --version \
  && aws_okta_keyman --help \
  && aws-connect -v \
  && aws-export-credentials --help \
  && aws-iam-authenticator \
  && aws-okta \
  && cloud-nuke \
  && confd -version \
  && cookiecutter -h \
  && eksctl \
  && fluxctl \
  && helm \
  && kompose -h \
  && kops \
  && kubectl \
  && kubectx --help \
  && kubens --help \
  && mssh --help \
  && okta-awscli --help \
  && sam --help \
  && session-manager-plugin --version \
  && terraform-docs \
  && terraform-latest -h \
  && terraform11 -h \
  && terraform12 -h \
  && terragrunt -h \
  && terragrunt18 -h

COPY bashrc /etc/bashrc

ENV SSH_AUTH_SOCK /tmp/agent.sock

EXPOSE 5555

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["ssh-agent", "-d", "-s", "-a", "/tmp/agent.sock"]
