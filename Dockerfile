FROM centos:centos7
MAINTAINER David Pelaez <david@vlipco.co>

ENV HOME /app

RUN mkdir -p /app && groupadd -r fakeuser -f -g 433 && \
  useradd -u 431 -r -g fakeuser -d /app -s /sbin/nologin -c "Fake User" fakeuser && \
  chown -R fakeuser:fakeuser /app

RUN yum upgrade -y && yum install -y vim unzip bzip2 tar gcc make automake gdbm-devel libffi-devel libyaml-devel \
  openssl-devel ncurses-devel readline-devel zlib-devel ruby-devel \
  libxml2 libxml2-devel libxslt libxslt-devel git mysql-devel sqlite-devel

RUN cd /usr/local/src && curl -L -s \
  "https://github.com/postmodern/ruby-install/archive/v0.4.3.tar.gz" \
  > ruby-install-0.4.3.tar.gz && \
  tar xzf ruby-install-0.4.3.tar.gz && cd ruby-install-0.4.3 && make install && \
  ruby-install -i /usr/local/ ruby $RUBY_VERSION -- --disable-install-rdoc 2> /dev/null && \
  rm -rf /usr/local/src/* && rm -rf /tmp/* && yum clean all

# skip installing gem documentation
RUN echo 'gem: --no-rdoc --no-ri' >> /.gemrc

RUN gem install bundler && bundle config build.nokogiri --use-system-libraries

WORKDIR /app
EXPOSE 5000
CMD [ "bundle", "exec", "foreman", "start"]

ONBUILD ADD Gemfile /app/
ONBUILD ADD Gemfile.lock /app/
ONBUILD RUN bundle install --system

ONBUILD ADD . /app
