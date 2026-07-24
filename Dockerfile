FROM debian:11

ENV DEBIAN_FRONTEND=noninteractive

# Add Koha APT repository
RUN apt-get update && apt-get install -y gnupg curl && \
    curl -s https://debian.koha-community.org/koha/gpg.asc | apt-key add - && \
    echo "deb http://debian.koha-community.org/koha stable main" > /etc/apt/sources.list.d/koha.list

# Install Koha
RUN apt-get update && apt-get install -y \
    koha-common \
    mariadb-client \
    apache2 \
    libapache2-mod-perl2 \
    curl wget ca-certificates \
    && apt-get clean

COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]