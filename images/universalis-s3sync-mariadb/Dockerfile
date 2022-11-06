FROM mariadb:10.3.32 AS runtime
WORKDIR /app
COPY dump-database.sh dump-database.sh
CMD [ "/app/dump-database.sh" ]