FROM wordpress:latest

ENV DOCUMENT_ROOT /usr/src/wordpress
ENV PROJECT "Cycloid Project"

# Installing dependencies
RUN apt-get update && apt-get install -y curl unzip sqlite && apt-get clean

# Download sqlite plugin for wordpress
RUN curl -o sqlite-plugin.zip https://downloads.wordpress.org/plugin/sqlite-integration.1.8.1.zip && unzip sqlite-plugin.zip -d ${DOCUMENT_ROOT}/wp-content/plugins/ && rm sqlite-plugin.zip
# create wordpress configuration
RUN cp ${DOCUMENT_ROOT}/wp-content/plugins/sqlite-integration/db.php ${DOCUMENT_ROOT}/wp-content

# configure database
COPY files/db.sql ${DOCUMENT_ROOT}/db.sql
RUN mkdir -p /var/wordpress/database && \
  chown -R 33:33 /var/wordpress
RUN sqlite3 /var/wordpress/database/.ht.sqlite < ${DOCUMENT_ROOT}/db.sql

# Copy cycloid content
COPY files/uploads ${DOCUMENT_ROOT}/wp-content/uploads/
COPY files/wp-config.php ${DOCUMENT_ROOT}/wp-config.php

# Display project name on frontpage
RUN sed -i "s/bloginfo( 'name' );/bloginfo( 'name' ); echo ' - ' . getenv('PROJECT');/g" ${DOCUMENT_ROOT}/wp-content/themes/twentyseventeen/template-parts/header/site-branding.php 

