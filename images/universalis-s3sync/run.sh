#!/bin/sh
aws configure import --csv file:///run/secrets/${AWS_SECRET_CSV}
aws s3 sync ${SYNC_SOURCE} ${SYNC_TARGET} --endpoint-url ${AWS_ENDPOINT} --profile ${AWS_PROFILE} --dryrun