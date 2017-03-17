# Pull Request Review Reminder Bot

Our team wants to be reminded via Slack about pending pull requests
after a certain number of work hours without activity. We calculate
work hours as the cumulative number of online hours since the pull
request was submitted.

## Setup

```
git clone https://github.com/seven1m/reviewbot
cd reviewbot
heroku apps:create NAME
heroku config:set \
  GH_AUTH_TOKEN=abc-123 \
  SLACK_TOKEN=xoxb-234 \
  CONFIG=$(cat config.json)
git push heroku
heroku addons:create scheduler:standard
heroku addons:open scheduler
```

The `reviewers` key is a JSON an array with a github username, slack username, and timezone identifier.

Now add a schedule for hourly with the command `rake remind`.

To test manually:

```
heroku run rake remind
```

## Copyright

Copyright Tim Morgan, Licensed MIT
