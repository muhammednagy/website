FROM node:4

RUN mkdir /opt/certbot
WORKDIR /opt/certbot

ENV NODE_ENV production
ENV RUBY_VERSION 2.2.2
ENV NOKOGIRI_USE_SYSTEM_LIBRARIES true

# Set UTF-8 character encoding
RUN apt-get update && apt-get install locales -y
RUN echo dpkg-reconfigure -f noninteractive tzdata && \
    sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    echo 'LANG="en_US.UTF-8"'>/etc/default/locale && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL C.UTF-8

# need rsync for deploy script
RUN apt-get install rsync -y

# Install ruby and dependencies
RUN echo 'gem: --no-document' >> /usr/local/etc/gemrc &&\
    mkdir /src && cd /src && git clone https://github.com/sstephenson/ruby-build.git &&\
    cd /src/ruby-build && ./install.sh &&\
    cd / && rm -rf /src/ruby-build && ruby-build $RUBY_VERSION /usr/local
RUN gem install jekyll html-proofer

# Install js dependencies
COPY package.json ./
RUN npm install gulp -g
RUN npm install

# Install docs dependencies
COPY _docs/ ./_docs
COPY _docs.sh ./
RUN apt-get install -y --no-install-recommends \
    texlive \
    texlive-latex-extra
RUN ./_docs.sh depend
RUN ./_docs.sh install

COPY _data ./_data
COPY _faq_entries ./_faq_entries
COPY _gulp ./_gulp
COPY _includes ./_includes
COPY _layouts ./_layouts
COPY _sass ./_sass
COPY _scripts ./_scripts
COPY about ./about
COPY all-instructions ./all-instructions
COPY faq ./faq
COPY fonts ./fonts
COPY images ./images
COPY privacy ./privacy
COPY support ./support
COPY _config.yml ./_config.yml
COPY favicon.ico ./favicon.ico
COPY gulpfile.js ./gulpfile.js
COPY index.html ./index.html
COPY certbot-deploy ./certbot-deploy
COPY .git ./.git
COPY .gitmodules ./.gitmodules

CMD ["bash"]
