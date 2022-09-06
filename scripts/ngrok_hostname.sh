#!/bin/sh

# ngrok's web interface is HTML, but configuration is bootstrapped as a JSON
# string. We can hack out the forwarded hostname by extracting the next
# `*.ngrok.io` string from the JSON
#
# Brittle as all get out--YMMV. If you're still reading, usage is:
#
#     $ ./ngrok_hostname.sh <proto> <addr>
#
# To retrieve the ngrok'd URL of an HTTP service running locally on :3332, use:
#
#     $ ./ngrok_hostname.sh http localhost:3332
#

# The address of the forwarded service
ADDR=$1

curl -s localhost:4040/api/tunnels | jq -r ".tunnels[] | select(.config[\"addr\"] == \"${ADDR}\" and .proto == \"https\") | .public_url"
