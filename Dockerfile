FROM centos
RUN yum install -y python-setuptools gcc python-devel
RUN yum install -y rsync
RUN easy_install pip
RUN pip install virtualenv
RUN yum install -y rubygems
RUN yum install -y ruby-devel
RUN gem install fpm
RUN yum install -y rpm-build
RUN yum install -y git
RUN yum install -y postgresql-devel
RUN yum install -y mysql
RUN yum install -y mysql-devel
