
hiwdiFROM php:7.4-apache

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libpng-dev \
    zlib1g-dev \
    libxml2-dev \
    libzip-dev \
    libonig-dev \
    zip \
    curl \
    unzip \
    && docker-php-ext-configure gd \
    && docker-php-ext-install -j$(nproc) gd pdo_mysql mbstring zip exif sockets

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Set working directory
WORKDIR /var/www/html

# Install Yii2 app
RUN composer create-project --prefer-dist yiisoft/yii2-app-basic .

# Configure Apache to use the /web directory
RUN sed -i 's|DocumentRoot /var/www/html|DocumentRoot /var/www/html/web|' /etc/apache2/sites-available/000-default.conf \
    && echo '<Directory /var/www/html/web>\n\
    AllowOverride All\n\
    Require all granted\n\
</Directory>' >> /etc/apache2/apache2.conf


# Apache configuration fix for .htaccess
RUN echo '<Directory /var/www/html>\n\
    AllowOverride All\n\
    Require all granted\n\
</Directory>' > /etc/apache2/conf-available/allow-override.conf \
    && a2enconf allow-override \
    && a2enmod rewrite

# Set correct permissions
RUN chown -R www-data:www-data /var/www/html \
    && find /var/www/html -type d -exec chmod 755 {} \; \
    && find /var/www/html -type f -exec chmod 644 {} \;

# Expose Apache port
EXPOSE 80
