# Based on https://github.com/aws/aws-cli/blob/v2/docker/Dockerfile
FROM mariadb:10.3.32 AS installer
RUN apt update -y \
    && apt install -y curl
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscliv2.zip
RUN apt update -y \
    && apt install -y unzip \
    && unzip awscliv2.zip \
    # The --bin-dir is specified so that we can copy the
    # entire bin directory from the installer stage into
    # into /usr/local/bin of the final stage without
    # accidentally copying over any other executables that
    # may be present in /usr/local/bin of the installer stage.
    && ./aws/install --bin-dir /aws-cli-bin/

FROM karashiiro/universalis-s3sync:latest AS s3sync

FROM mariadb:10.3.32 AS runtime
WORKDIR /app
RUN apt update -y \
    && apt install -y less groff \
    && apt clean
COPY --from=installer /usr/local/aws-cli/ /usr/local/aws-cli/
COPY --from=installer /aws-cli-bin/ /usr/local/bin/
COPY --from=s3sync /app/run.sh sync.sh
COPY dump-database.sh dump-database.sh
CMD [ "/app/dump-database.sh" ]