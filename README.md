# Pull Request Review Reminder Bot

Our team wanted to be reminded via Slack at regular intervals during the day (2 specific times each day)
about pending Pull Requests, so this little Ruby rake task was created.

## Setup

```
git clone https://github.com/seven1m/reviewbot
cd reviewbot
heroku apps:create NAME
heroku config:set \
  GH_AUTH_TOKEN=abc-123 \
  SLACK_TOKEN=xoxb-234 \
  OWNER=github-org-or-user \
  CONFIG='{"repo_name":{"reviewers":{"seven1m":"tim"},"days":[1,2,3,4,5],"hours":[10,15]}}' \
  TIMEZONE="America/Los_Angeles"
git push heroku
heroku addons:create scheduler:standard
heroku addons:open scheduler
```

The `reviewers` key is a JSON object where the key is the GitHub username and the value is the corresponding Slack username.

Now add a schedule for hourly with the command `rake remind`.

To test manually:

```
heroku run rake remind
```

## Copyright

Copyright Tim Morgan, Licensed MIT
