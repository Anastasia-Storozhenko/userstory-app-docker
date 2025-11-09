FROM mariadb:11
ENV MYSQL_ROOT_PASSWORD=rootpass
ENV MYSQL_DATABASE=userstory
ENV MYSQL_USER=userstory_user
ENV MYSQL_PASSWORD=userstory_pass
COPY init.sql /docker-entrypoint-initdb.d/
EXPOSE 3306