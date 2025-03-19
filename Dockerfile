# Use PHP with Apache
FROM php:8.2

# Install required system dependencies
RUN apt-get update && apt-get install -y \
    libzip-dev zip unzip curl git libpng-dev pkg-config libssl-dev \
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
WORKDIR /var/www/html/laravel

# Copy Laravel project
COPY . .

# Install Laravel dependencies
RUN composer install --no-dev 

# Set permissions
RUN chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

USER 10014
# Expose Apache port
EXPOSE 80

# Start Apache
# CMD ["apache2-foreground"]
