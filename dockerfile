FROM ubuntu:18.04

# Basic dependencies
RUN apt-get update
RUN apt-get install -y curl
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y git-core zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev software-properties-common libffi-dev nodejs yarn

# Setup Ruby
RUN apt-get install -y rbenv ruby-build ruby-dev
RUN git clone https://github.com/rbenv/rbenv.git ~/.rbenv
RUN echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
RUN echo 'eval "$(rbenv init -)"' >> ~/.bashrc
RUN exec $SHELL

RUN git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
RUN echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bashrc
RUN exec $SHELL

RUN rbenv install 2.6.5
RUN rbenv global 2.6.5

# Setup gems
RUN gem install bundler
RUN rbenv rehash
RUN gem update --system
RUN gem update
RUN gem install rails -v 6.0.2.1
RUN rbenv rehash

# Setup database (extra lines are for tzdata)
RUN export DEBIAN_FRONTEND=noninteractive 
RUN ln -fs /usr/share/zoneinfo/Asia/Singapore /etc/localtime
RUN apt-get install -y tzdata
RUN dpkg-reconfigure --frontend noninteractive tzdata
RUN apt-get install -y postgresql libpq-dev

# Clone this repo and install gems
RUN git clone https://github.com/wltan/cvwo-assignment.git
WORKDIR /cvwo-assignment/code
RUN bundle install

# Start the server
CMD rails s