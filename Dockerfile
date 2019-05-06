FROM montefuscolo/php:7.1-apache
MAINTAINER Rodrigo Severo <rodrigo@fabricadeideias.com>

ARG TIKI_SOURCE="https://sourceforge.net/projects/tikiwiki/files/Tiki_18.x_Alcyone/18.3/tiki-18.3.tar.gz/download"
WORKDIR "/var/www/html"
ARG SESSIONS_DIR="/var/www/sessions"

# If you have https_proxy with SslBump, place it's cetificate
# in this variable to have curl and composer content cached
ARG HTTPS_PROXY_CERT=""

RUN echo "${HTTPS_PROXY_CERT}" > /usr/local/share/ca-certificates/https_proxy.crt \
    && update-ca-certificates \
    && curl -o tiki.tar.gz -L "${TIKI_SOURCE}" \
    && chown root: ${WORKDIR} \
    && tar -C ${WORKDIR} --no-same-owner -zxf tiki.tar.gz --strip 1 \
    && composer global require hirak/prestissimo \
    && composer install --working-dir ${WORKDIR}/vendor_bundled --prefer-dist \
    && rm tiki.tar.gz \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* \ 
    && rm -rf /root/.composer \
    && { \
        echo "<?php"; \
        echo "    \$db_tiki        = getenv('TIKI_DB_DRIVER') ?: 'mysqli';"; \
        echo "    \$dbversion_tiki = getenv('TIKI_DB_VERSION') ?: '18';"; \
        echo "    \$host_tiki      = getenv('TIKI_DB_HOST') ?: 'db';"; \
        echo "    \$user_tiki      = getenv('TIKI_DB_USER');"; \
        echo "    \$pass_tiki      = getenv('TIKI_DB_PASS');"; \
        echo "    \$dbs_tiki       = getenv('TIKI_DB_NAME') ?: 'tikiwiki';"; \
    } > ${WORKDIR}/db/local.php \
    && {\
        echo "session.save_path=${SESSIONS_DIR}"; \
    }  > /usr/local/etc/php/conf.d/tiki_session.ini \
    && /bin/bash htaccess.sh \
    && mkdir -p ${SESSIONS_DIR} \
    && chown -R www-data ${SESSIONS_DIR} \
    && chown -R www-data ${WORKDIR}/db/ \
    && chown -R www-data ${WORKDIR}/dump/ \
    && chown -R www-data ${WORKDIR}/img/trackers/ \
    && chown -R www-data ${WORKDIR}/img/wiki/ \
    && chown -R www-data ${WORKDIR}/img/wiki_up/ \
    && chown -R www-data ${WORKDIR}/modules/cache/ \
    && chown -R www-data ${WORKDIR}/temp/ \
    && chown -R www-data ${WORKDIR}/templates/

VOLUME [ \
    "${WORKDIR}/files/", \
    "${WORKDIR}/img/trackers/", \
    "${WORKDIR}/img/wiki_up/", \
    "${WORKDIR}/img/wiki/", \
    "${WORKDIR}/modules/cache/", \
    "${WORKDIR}/storage/", \
    "${WORKDIR}/temp/", \
    "${SESSIONS_DIR}/" \
]
EXPOSE 80 443
CMD ["apache2-foreground"]
