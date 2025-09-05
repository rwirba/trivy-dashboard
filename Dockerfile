FROM registry.access.redhat.com/ubi9/ubi

RUN dnf -y install httpd && dnf clean all

# non-root + dirs
RUN useradd -u 10001 nobody && \
    mkdir -p /var/www/html /data/reports && \
    chown -R nobody:nobody /var/www/html /data/reports

# app files
COPY --chown=web:web dashboard.html /var/www/html/
COPY --chown=web:web assets/ /var/www/html/assets/

# minimalist httpd config (port 8080 + autoindex under /reports)
RUN printf '%s\n' \
  'ServerName 0.0.0.0' \
  'Listen 8080' \
  'DocumentRoot "/var/www/html"' \
  '<Directory "/var/www/html">' \
  '  Options -Indexes +FollowSymLinks' \
  '  AllowOverride None' \
  '  Require all granted' \
  '</Directory>' \
  'Alias "/reports" "/data/reports"' \
  '<Directory "/data/reports">' \
  '  Options +Indexes' \
  '  AllowOverride None' \
  '  Require all granted' \
  '</Directory>' \
  > /etc/httpd/conf/httpd.conf

USER nobody
EXPOSE 8080
CMD ["/usr/sbin/httpd","-D","FOREGROUND","-f","/etc/httpd/conf/httpd.conf"]
