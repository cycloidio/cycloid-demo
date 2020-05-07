FROM wordpress:latest

ENV DOCUMENT_ROOT /usr/src/wordpress
ENV PROJECT "cycloid"
ENV ENV demo

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
RUN sed -i "s/bloginfo( 'name' );/bloginfo( 'name' ); echo ' - ' . getenv('PROJECT') . ' ' . getenv('ENV');/g" ${DOCUMENT_ROOT}/wp-content/themes/twentyseventeen/template-parts/header/site-branding.php 

# rEMOVE SYMLINK On log files cause we want to use fluentd now
RUN unlink /var/log/apache2/access.log && touch /var/log/apache2/access.log && chmod 777 /var/log/apache2/access.log
RUN unlink /var/log/apache2/error.log && touch /var/log/apache2/error.log && chmod 777 /var/log/apache2/error.log

# Install fluentd for cycloid logs
RUN apt-get update && \
apt-get install -y  --no-install-recommends gnupg && \
curl https://packages.treasuredata.com/GPG-KEY-td-agent | apt-key add - && \
echo "deb https://packages.treasuredata.com/3/debian/stretch/ stretch contrib" > /etc/apt/sources.list.d/fluentd.list && \
apt-get update && \
apt-get install -y  --no-install-recommends td-agent gettext-base && \
apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy fluentd config
COPY files/td-agent.conf.template /etc/td-agent/td-agent.conf.template

# Install fluentd cloudwatch plugin
RUN /opt/td-agent/embedded/bin/fluent-gem install fluent-plugin-cloudwatch-logs

# Run apache2 AND fluentd to report logs to CW
RUN sed -i 's/exec apache2 -DFOREGROUND "$@"/apache2 "$@" \nexec td-agent/' /usr/local/bin/apache2-foreground

# Copy cycloid entrypoint for tdagent
COPY files/entrypoint.sh /bin/entrypoint.sh
#CMD /bin/entrypoint.sh
ENTRYPOINT /bin/entrypoint.sh
