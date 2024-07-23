Laravel Development Setup
This repository provides a setup for running a Laravel application with Docker, including a MySQL database.

Prerequisites
Docker Desktop

 Clone the repository:
 ```shell
git clone https://github.com/hexstories/testphp.git
```

Setup Instructions
Step 1: Create a new Laravel project

Step 2: Create a Dockerfile
Create a file named Dockerfile in your project root with the following content:
 ```shell
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

```

Step 3: Create a docker-compose.yml
Create a file named docker-compose.yml in your project root with the following content:
 ```shell
version: '3.8'

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: laravel-app
    image: laravel-app:latest
    restart: unless-stopped
    working_dir: /var/www
    volumes:
      - .:/var/www
    networks:
      - laravel-network
    ports:
      - "8000:9000"
    environment:
      - DB_CONNECTION=mysql
      - DB_HOST=mysql
      - DB_PORT=3306
      - DB_DATABASE=laravel
      - DB_USERNAME=root
      - DB_PASSWORD=root
    depends_on:
      - mysql

  mysql:
    image: mysql:8.0
    container_name: mysql-db
    restart: unless-stopped
    volumes:
      - mysql-data:/var/lib/mysql
    environment:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_DATABASE: laravel
      MYSQL_USER: root
      MYSQL_PASSWORD: root
    networks:
      - laravel-network

volumes:
  mysql-data:

networks:
  laravel-network:
    driver: bridge

```

Step 4: Update the .env file
Ensure your .env file has the following database settings:
 DB_CONNECTION=mysql
DB_HOST=db
DB_PORT=3306
DB_DATABASE=laravel
DB_USERNAME=laravel_user
DB_PASSWORD=laravel_password


Step 5: Build and run the containers
Run the following commands in your project root:
 ```shell
docker-compose up --build
docker-compose exec app php artisan migrate

```

