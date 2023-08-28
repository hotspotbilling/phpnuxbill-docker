# Startup from alpine
FROM alpine:latest
LABEL Maintainer = "Hilman Maulana, Ibnu Maksum"
LABEL Description = "PHPNuxBill (PHP Mikrotik Billing) is a web-based application (MikroTik API PHP class) Voucher management for MikroTik Hotspot."

# Setup document root
WORKDIR /var/www/html

# Expose the port nginx is reachable on
EXPOSE 80
EXPOSE 3306

# Install packages
RUN apk add --no-cache \
    nginx \
    php \
    php-fpm \
    php-gd \
    php-mbstring \
    php-mysqli \
    php-session \
    php-pdo \
    php-pdo_mysql \
    php-zip \
    php-xml \
    php-intl \
    php-curl \
    php-json \
    php-simplexml \
    php-cli \
    mysql \
    mysql-client \
    git \
    supervisor

# Configure nginx
COPY conf/nginx.conf /etc/nginx/nginx.conf

# Configure Cron
COPY conf/phpnuxbill-cron /etc/cron.d/phpnuxbill-cron
RUN chmod 0644 /etc/cron.d/phpnuxbill-cron
RUN crontab /etc/cron.d/phpnuxbill-cron

# Configure MySQL
COPY conf/my.cnf /etc/mysql/my.cnf
COPY conf/mysql.sh /app/mysql.sh
RUN chmod +x /app/mysql.sh

# Configure PHP-FPM
COPY conf/fpm-pool.conf /etc/php/php-fpm.d/www.conf
COPY conf/php.ini /etc/php/conf.d/custom.ini

# Configure supervisord
COPY conf/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN git clone https://github.com/hotspotbilling/phpnuxbill.git /var/www/html/
RUN cp -R /var/www/html/pages_template /var/www/html/pages
# Add application
RUN chown -R nginx:nginx /var/www/html/

# Let supervisord start nginx & php-fpm
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
