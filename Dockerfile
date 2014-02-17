FROM centos
RUN yum update -y
RUN yum install -y python-setuptools gcc python-devel rsync rubygems ruby-devel rpm-build git postgresql-devel mysql mysql-devel
RUN easy_install pip
RUN pip install virtualenv
RUN gem install fpm
