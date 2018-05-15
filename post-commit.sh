#!/bin/bash
# Run tests after commit and notify a Slack channel
webhook_url="https://expresscloud.slack.com/services/hooks/incoming-webhook?token=hWVSzSvmLParoxvraTH287S0"
channel="#jenkinsnotification"

r=/home/ubuntu/devops/github/devops
cd $r
root=$(git rev-parse --show-toplevel)
cd $root
repo=$(basename $root)
user=prtkdave
#user=$(git config --global --get user.name)
output=$(bundle exec rake test)
output=$(echo $output | sed 's/.*\(Finished tests in [0-9.]\+s, [0-9.]\+ tests\/s, [0-9.]\+ assertions\/s\.\).*[^0-9]\([0-9]\+ tests, .*\)/\1 \2/g' | sed 's/Finished tests/executed tests/g')
rev=$(git log -1 --format=format:%h)
ref=$(git rev-parse --abbrev-ref HEAD)
cd - >/dev/null
msg=$(echo "Build $rev of $repo/$ref by $user $output")
curl -X POST --data-urlencode "payload={\"channel\": \"$channel\", \"username\": \"Git CI\", \"text\": \"$msg\"}" $webhook_url
exit 0
