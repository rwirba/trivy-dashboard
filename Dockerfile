FROM registry.access.redhat.com/ubi9/ubi

# Install Apache httpd
RUN dnf -y install httpd && dnf clean all

# Create service user only if it doesn't exist, and prepare writable dirs
# (httpd needs /run/httpd for its PID file when not running as root)
RUN id -u nobody >/dev/null 2>&1 || useradd -u 10001 -r -s /sbin/nologin nobody; \
    mkdir -p /var/www/html /data/reports /run/httpd; \
    chown -R nobody:nobody /var/www/html /data/reports /run/httpd

# App files (own by nobody)
COPY --chown=nobody:nobody dashboard.html /var/www/html/index.html
# Optional: if you have an assets/ dir, this keeps it optional without failing
# (comment out if you always have /assets)
# COPY --chown=nobody:nobody assets/ /var/www/html/assets/

# Minimal httpd config: listen on 8080, serve /, list /reports, non-root friendly
RUN printf '%s\n' \
  'ServerName 0.0.0.0' \
  'Listen 8080' \
  'PidFile /run/httpd/httpd.pid' \
  'DocumentRoot "/var/www/html"' \
  'DirectoryIndex index.html' \
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
