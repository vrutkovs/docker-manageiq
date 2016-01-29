FROM centos:7

MAINTAINER Vadim Rutkovsky, https://github.com/vrutkovs

RUN yum -y install https://www.softwarecollections.org/en/scls/rhscl/rh-ruby22/epel-7-x86_64/download/rhscl-rh-ruby22-epel-7-x86_64.noarch.rpm
RUN yum -y install scl-utils \
        rh-ruby22-ruby-devel \
        rh-ruby22-rubygems-devel \
        rh-ruby22-rubygem-rake \
        rh-ruby22-rubygem-bundler \
        rh-ruby22-rubygem-json \
# Important utils
        git \
        tar \
        postgresql-client \
        postgresql-devel \
        memcached \
# Gem's build requirements
        gcc \
        gcc-c++ \
        libxml2-devel \
        libxslt-devel \
        make \
        patch \
        which \
        bzip2

EXPOSE 3000 4000

COPY install.sh /
RUN chmod +x install.sh
COPY database.openshift.yml /
RUN /bin/bash -l /install.sh

COPY run.sh /
RUN chmod +x run.sh
CMD /bin/bash -l /run.sh
