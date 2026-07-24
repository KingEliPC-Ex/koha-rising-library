#!/bin/bash
set -e

apt-get update
apt-get install -y --no-install-recommends \
  git build-essential libapache2-mod-perl2 apache2 \
  libdbi-perl libdbd-mysql-perl libxml-libxml-perl \
  libxml-libxslt-perl libjson-perl libyaml-perl \
  libdatetime-perl libdatetime-format-strptime-perl \
  libtemplate-perl libtext-csv-perl libarchive-zip-perl \
  libsoap-lite-perl libnet-ldap-perl libdigest-sha-perl \
  libio-socket-ssl-perl libcrypt-eksblowfish-perl \
  libunicode-linebreak-perl libunicode-string-perl \
  libplack-middleware-session-perl \
  libxml2-utils curl wget ca-certificates \
  libcache-cache-perl memcached perl-modules

# Install cpanminus and common CPAN modules used by Koha
curl -L https://cpanmin.us | perl - --sudo App::cpanminus
cpanm --notest --installdeps /usr/src/koha || true

# Clean
apt-get clean
rm -rf /var/lib/apt/lists/*
