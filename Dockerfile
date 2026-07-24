FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV KOHA_INSTANCE=${KOHA_INSTANCE:-kohadev}
ENV KOHA_HOME=/var/lib/koha
ENV KOHA_ETC=/etc/koha
ENV PATH=/usr/local/bin:$PATH

# Install base packages and Koha build deps
COPY build-scripts/install-koha-deps.sh /tmp/install-koha-deps.sh
RUN chmod +x /tmp/install-koha-deps.sh && /tmp/install-koha-deps.sh

# Clone Koha source
ARG KOHA_GIT
ARG KOHA_BRANCH
RUN git clone --depth 1 --branch ${KOHA_BRANCH} ${KOHA_GIT} /usr/src/koha

# Install Koha Perl modules and packaging
WORKDIR /usr/src/koha
RUN perl Makefile.PL && make && make install

# Create directories and default permissions
RUN mkdir -p ${KOHA_HOME} ${KOHA_ETC} /var/run/zebra /var/log/koha \
    && useradd -m -d /var/lib/koha koha || true \
    && chown -R koha:koha ${KOHA_HOME} ${KOHA_ETC} /var/run/zebra /var/log/koha

# Copy entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8080 8081

VOLUME ["/var/lib/mysql","/var/lib/koha","/etc/koha/sites"]

ENTRYPOINT ["/entrypoint.sh"]
CMD ["tail","-f","/dev/null"]
