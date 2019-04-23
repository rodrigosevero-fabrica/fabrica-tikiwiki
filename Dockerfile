FROM rodrigosevero/apache-php-alpine
MAINTAINER Rodrigo Severo <rodrigo@fabricadeideias.com>

ARG TIKI_SOURCE="https://sourceforge.net/projects/tikiwiki/files/Tiki_19.x_Denebola/19.1/tiki-19.1.tar.gz/download"
ARG TIKI_HTDOCS="/var/www/html"
WORKDIR "${TIKI_HTDOCS}"

RUN wget -O tiki.tar.gz "${TIKI_SOURCE}" \
    && tar -C ${TIKI_HTDOCS} -zxf tiki.tar.gz --strip 1 \
    && rm tiki.tar.gz \
    && { \
        echo "<?php"; \
        echo "    \$db_tiki        = getenv('TIKI_DB_DRIVER') ?: 'mysqli';"; \
        echo "    \$dbversion_tiki = getenv('TIKI_DB_VERSION') ?: '19';"; \
        echo "    \$host_tiki      = getenv('TIKI_DB_HOST') ?: 'db';"; \
        echo "    \$user_tiki      = getenv('TIKI_DB_USER');"; \
        echo "    \$pass_tiki      = getenv('TIKI_DB_PASS');"; \
        echo "    \$dbs_tiki       = getenv('TIKI_DB_NAME') ?: 'tikiwiki';"; \
        echo "    \$client_charset = 'utf8';"; \
    } > ${TIKI_HTDOCS}/db/local.php \
    && mv _htaccess .htaccess \
    && composer install --working-dir ${TIKI_HTDOCS}/vendor_bundled --prefer-dist \
    && chown -R root:root /var \
    && find ${TIKI_HTDOCS} -type f -exec chmod 644 {} \; \
    && find ${TIKI_HTDOCS} -type d -exec chmod 755 {} \; \
    && chown -R apache ${TIKI_HTDOCS}/db/ \
    && chown -R apache ${TIKI_HTDOCS}/dump/ \
    && chown -R apache ${TIKI_HTDOCS}/img/trackers/ \
    && chown -R apache ${TIKI_HTDOCS}/img/wiki/ \
    && chown -R apache ${TIKI_HTDOCS}/img/wiki_up/ \
    && chown -R apache ${TIKI_HTDOCS}/modules/cache/ \
    && chown -R apache ${TIKI_HTDOCS}/temp/ \
    && chown -R apache ${TIKI_HTDOCS}/temp/cache/ \
    && chown -R apache ${TIKI_HTDOCS}/temp/templates_c/ \
    && chown -R apache ${TIKI_HTDOCS}/templates/ \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/*


VOLUME [                            \
    "${TIKI_HTDOCS}/files/",        \
    "${TIKI_HTDOCS}/img/wiki/",     \
    "${TIKI_HTDOCS}/img/wiki_up/",  \
    "${TIKI_HTDOCS}/img/trackers/"  \
]

EXPOSE 80 443
CMD ["apache2-foreground"]
