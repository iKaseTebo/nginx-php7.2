FROM ikasetebo/nginx:v0.01

WORKDIR /
COPY ./entrypoint/entrypoint.sh /

RUN apt-get -y update \
    && apt-get -y upgrade \
    && apt-get install -y software-properties-common \
    -y python-software-properties \
    -y language-pack-en-base  \
    && LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php \
    && apt-get -y update \
    && apt-get install -y php7.2 \
    -y php-pear \
    -y php7.2-curl \
    -y php7.2-dev \
    -y php7.2-gd \
    -y php7.2-fpm \
    -y php7.2-cli \
    -y php7.2-cgi \
    -y php7.2-mysql \
    -y php7.2-mbstring \
    -y php7.2-xml \
    -y php7.2-zip \
    -y unzip \
    -y ufw \
    -y apt-utils \
    -y dialog \
    -y dos2unix \
    && dos2unix ./entrypoint.sh \
    && curl -sS https://getcomposer.org/installer -o composer-setup.php \
    && php -r "if (hash_file('SHA384', 'composer-setup.php') === '544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
    && php composer-setup.php --instal-dir /usr/local/bin --filename=composer \
    && mv composer /usr/local/bin/composer \
    && chmod +x /usr/local/bin/composer \
    && ln -sf /shared/stdout /var/log/nginx/access.log \
    && ln -sf /shared/stderr /var/log/nginx/error.log

COPY ./nginx-conf/sites-enabled/default /etc/nginx/sites-enabled/default
COPY ./nginx-conf/nginx.conf /etc/nginx/nginx.conf
COPY ./nginx-conf/ssl/nginx.crt /etc/nginx/ssl/nginx.crt
COPY ./nginx-conf/ssl/nginx.key /etc/nginx/ssl/nginx.key
COPY ./php-conf/php.ini  /etc/php/7.2/fpm/php.ini
COPY ./app/index.php /usr/share/nginx/html/index.php

VOLUME ["/shared/", "/usr/share/nginx/html/"]

EXPOSE 80 443