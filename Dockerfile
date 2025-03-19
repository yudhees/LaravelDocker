# Use PHP with Apache
FROM php:8.2-fpm

# Install required system dependencies
RUN apt-get update && apt-get install -y \
    libzip-dev zip unzip curl git libpng-dev pkg-config libssl-dev nginx supervisor \
    && pecl install mongodb \
    && docker-php-ext-enable mongodb

# Clear APT cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN groupadd -g 10014 choreo && \
    useradd --no-create-home --uid 10014 --gid 10014 --system choreouser 
# Set Apache ServerName to avoid warnings
# RUN echo "ServerName localhost" >> /etc/apache2/conf-available/servername.conf \
    # && a2enconf servername

# Enable Apache mod_rewrite for Laravel routes
# RUN a2enmod rewrite

# Set working directory
WORKDIR  /var/www/app/laravel

# Copy Laravel project
COPY . .

# Install Laravel dependencies
RUN composer install --no-dev 

RUN mkdir -p /var/www/app/laravel/storage \
    /var/www/app/laravel/bootstrap/cache \
    /var/log/supervisor \
    && chown -R www-data:www-data /var/www/app/laravel/storage \
    /var/www/app/laravel/bootstrap/cache \
    /var/log/supervisor \
    && chmod -R 775 /var/www/app/laravel/storage \
    /var/www/app/laravel/bootstrap/cache \
    /var/log/supervisor

# Ensure Supervisor log file is writable
RUN touch /var/log/supervisor/supervisord.log && \
    chown www-data:www-data /var/log/supervisor/supervisord.log
    
COPY nginx.conf /etc/nginx/sites-available/default
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
# Expose Apache port
USER 10014
EXPOSE 80

# Start Apache
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
