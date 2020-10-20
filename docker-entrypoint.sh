#!/bin/bash

set -eu -o pipefail

# Configure MSMTP based on environment variables

## Defaults
if [[ ! -v MSMTP_PORT ]];then
  MSMTP_PORT=587
fi

## Substitute values
if [[ -v MSMTP_HOST ]]; then
 sed -i -r "s|MSMTP_HOST|${MSMTP_HOST/|/\\|}|g" "$HOME/.msmtprc"
fi
  sed -i -r "s|MSMTP_PORT|${MSMTP_PORT/|/\\|}|g" "$HOME/.msmtprc"
if [[ -v MSMTP_USER ]]; then
  sed -i -r "s|MSMTP_USER|${MSMTP_USER/|/\\|}|g" "$HOME/.msmtprc"
fi
if [[ -v MSMTP_PASSWORD ]]; then
  sed -i -r "s|MSMTP_PASSWORD|${MSMTP_PASSWORD/|/\\|}|g" "$HOME/.msmtprc"
fi
if [[ -v MSMTP_FROM ]]; then
  sed -i -r "s|MSMTP_FROM|${MSMTP_FROM/|/\\|}|g" "$HOME/.msmtprc"
fi

# Do nothing. This will be used as a workspace.
touch /tmp/test
tail -f /tmp/test
