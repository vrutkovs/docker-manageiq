FROM centos/postgresql

MAINTAINER Vadim Rutkovsky, https://github.com/vrutkovs
#inspired by http://manageiq.org/community/install-from-source/

RUN yum -y install tar git sudo postgresql-devel memcached

# 1. SCL
#RUN yum -y install postgresql-devel memcached gcc-c++  libxml2-devel libxslt libxslt-devel
#RUN yum -y install https://www.softwarecollections.org/en/scls/rhscl/rh-ruby22/epel-7-x86_64/download/rhscl-rh-ruby22-epel-7-x86_64.noarch.rpm
#RUN yum -y install scl-utils rh-ruby22*
#RUN scl enable rh-ruby22 bash

# 2. RVM
RUN yum install -y ruby-devel nodejs npm
RUN command curl -sSL https://rvm.io/mpapis.asc | gpg2 --import -
RUN curl -sSL https://get.rvm.io | rvm_tar_command=tar bash -s stable
RUN source /etc/profile.d/rvm.sh
RUN echo "gem: --no-ri --no-rdoc --no-document" > ~/.gemrc
RUN /bin/bash -l -c "rvm requirements"
RUN /bin/bash -l -c "rvm install ruby 2.3.0"
RUN /bin/bash -l -c "rvm use 2.3.0 --default"
RUN /bin/bash -l -c "gem install bundler rake"


# Preinstall biggest gems which require a long compilation time
RUN yum install -y libxml2-devel libxslt-devel
RUN /bin/bash -l -c "gem install nokogiri -- --use-system-libraries"

EXPOSE 3000 4000

COPY createDB.sh /
RUN chmod +x createDB.sh
COPY install.sh /
RUN chmod +x install.sh
CMD /bin/bash -l /install.sh
