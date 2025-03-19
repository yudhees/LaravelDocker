FROM php:8.2

RUN apt-get update && apt-get install -y \
    libzip-dev \
    zip

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install MongoDB PHP extension
RUN pecl install mongodb \
&& docker-php-ext-enable mongodb

# Set working directory to Apache's root
WORKDIR /var/www/app

# Copy Laravel project
COPY . /var/www/app

# Install dependencies without dev packages
RUN composer install --no-dev 

# Set permissions
RUN chmod -R 775 storage bootstrap/cache

