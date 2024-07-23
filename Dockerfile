# Use the official PHP image as a base
FROM php:8.2-fpm

# Install system dependencies and PHP extensions
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    unzip \
    git \
    libonig-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    libmcrypt-dev \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd \
    && docker-php-ext-install mbstring exif pcntl bcmath curl zip

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Set the working directory in the container
WORKDIR /var/www

# Copy the application code into the container
COPY . .

# Install PHP dependencies
RUN composer install --no-interaction --no-ansi --no-dev --no-scripts --no-progress

# Copy the .env.example to .env
RUN cp .env.example .env

# Generate the application key
RUN php artisan key:generate

# Expose the port on which the PHP-FPM server will run
EXPOSE 9000

# Start PHP-FPM server
CMD ["php-fpm"]

