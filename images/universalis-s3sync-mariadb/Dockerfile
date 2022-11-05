FROM karashiiro/universalis-s3sync:latest AS base
FROM mariadb:10.3.32 AS runtime
WORKDIR /app
COPY --from=base /app/run.sh run.sh
COPY dump-database.sh dump-database.sh
CMD [ "dump-database.sh" ]