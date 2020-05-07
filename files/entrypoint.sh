#!/bin/sh

export AWS_REGION="${AWS_REGION:-eu-west-1}"

envsubst '$AWS_REGION $ENV $PROJECT' < /etc/td-agent/td-agent.conf.template > /etc/td-agent/td-agent.conf
docker-entrypoint.sh apache2-foreground
#apache2-foreground $@
#exec apache2-foreground $@
