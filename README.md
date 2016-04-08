# Pull Request Remindbot

Our team wanted to be reminded at regular intervals during the day (2 specific times each day) about pending Pull Requests,
so this little Ruby rake task was created.

## Setup

```
git clone https://github.com/seven1m/remindbot
cd remindbot
heroku apps:create NAME
heroku config:set \
  GH_AUTH_TOKEN=abc-123 \
  SLACK_TOKEN=xoxb-234 \
  OWNER=github-org-or-user \
  REPO=github-repo \
  TIMEZONE="America/Los_Angeles" \
  REVIEW_HOURS="[10,15]" \
  REVIEWERS='{"github-username":"slack-username","seven1m":"tim"}'
git push heroku
heroku addons:create scheduler:standard
heroku addons:open scheduler
```

Now add a schedule for hourly with the command `rake remind`.

To test manually:

```
heroku run rake remind
```

## Copyright

Copyright Tim Morgan, Licensed MIT
