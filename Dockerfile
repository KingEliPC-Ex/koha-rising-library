FROM debian:11

ENV DEBIAN_FRONTEND=noninteractive

# Add Koha APT repository
RUN apt-get update && apt-get install -y gnupg curl && \
    curl -s https://debian.koha-community.org/koha/gpg.asc | apt-key add - && \
    echo "deb http://debian.koha-community.org/koha stable main" > /etc/apt/sources.list.d/koha.list

# Install Koha + Apache + MySQL client
RUN apt-get update && apt-get install -y \
    koha-common \
    mariadb-client \
    apache2 \
    libapache2-mod-perl2 \
    curl wget ca-certificates \
    && apt-get clean

# Enable required Apache modules
RUN a2enmod rewrite
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Copy entrypoint
COPY ./entrypoint.sh /entrypoint.sh
RUN sed -i 's/\r$//' /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Use CMD instead of ENTRYPOINT so you can debug with `docker run -it image bash`
CMD ["/entrypoint.sh"]