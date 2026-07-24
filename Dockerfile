FROM debian:11

ENV DEBIAN_FRONTEND=noninteractive

# Install Koha dependencies
RUN apt-get update && apt-get install -y \
    git build-essential \
    libdbi-perl libdbd-mysql-perl \
    libxml-libxml-perl libxml-libxslt-perl \
    libjson-perl libyaml-perl \
    libdatetime-perl libdatetime-format-strptime-perl \
    libtemplate-perl libtext-csv-perl \
    libarchive-zip-perl libsoap-lite-perl \
    libnet-ldap-perl libdigest-sha-perl \
    libio-socket-ssl-perl libcrypt-eksblowfish-perl \
    libunicode-linebreak-perl libunicode-string-perl \
    libplack-perl libplack-middleware-session-perl \
    libplack-middleware-rewrite-perl \
    libplack-handler-starman-perl \
    libzebra-perl \
    apache2 libapache2-mod-perl2 \
    mariadb-client \
    curl wget ca-certificates \
    && apt-get clean

# Clone Koha source
RUN git clone --depth 1 https://gitlab.com/koha-community/koha.git /usr/src/koha

WORKDIR /usr/src/koha

# Build Koha
RUN perl Makefile.PL && make && make install

# Create directories
RUN mkdir -p /var/lib/koha /etc/koha/sites /var/log/koha \
    && useradd -m -d /var/lib/koha koha \
    && chown -R koha:koha /var/lib/koha /etc/koha/sites /var/log/koha

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]