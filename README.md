# Pull Request Review Reminder Bot

![Example Slack Message](https://raw.github.com/danielma/reviewbot/master/docs/images/slack-example.png)

Our team wants to be reminded via Slack about pending pull requests
after a certain number of work hours without activity. We calculate
work hours as the cumulative number of online hours since the pull
request was submitted.

## Setup

#### Create Github Access Token

1. Visit https://github.com/settings/tokens
2. Click "Generate New Token"
3. Select "repo" permissions

![Github Access Token Permissions](https://raw.github.com/danielma/reviewbot/master/docs/images/github-token-permissions.png)

#### Create Slack Legacy Token

1. Visit https://api.slack.com/custom-integrations/legacy-tokens
2. Issue a token if one does not exist

![Slack Legacy Token Generation](https://raw.github.com/danielma/reviewbot/master/docs/images/slack-token.png)

#### Configure Repos

```
cp sample-config.json config.json
```

Edit `config.json` to match the needs of your team. Each key in the configuration defines a repo, the channel messages for the repo should be posted to, the reviewers responsible for that repo, and the period of inactivity to notify reviewers after. 

The `reviewers` key is a JSON array containing a github username, slack username, and timezone identifier for each reviewer.

##### Example Config

```json
{
  "danielma/reviewbot": {
    "room": "#reviewbot",
    "reviewers": [
      {
        "github": "danielma",
        "slack": "dma",
        "timezone": "America/Los_Angeles"
      },
      {
        "github": "contributor",
        "slack": "dmas_evil_twin",
        "timezone": "America/New_York"
      }
    ],
    "hours_to_review": 6
  }
}
```

#### Create Application
```
git clone https://github.com/danielma/reviewbot
cd reviewbot
heroku apps:create NAME
heroku config:set \
  GH_AUTH_TOKEN=abc-123 \
  SLACK_TOKEN=xoxb-234 \
  CONFIG="$(cat config.json)"
git push heroku
heroku addons:create scheduler:standard
heroku addons:open scheduler
```

![Heroku Scheduler Task Creation](https://raw.github.com/danielma/reviewbot/master/docs/images/heroku-scheduler.png)

## Testing

### Manual Test:

```
heroku run rake remind
```

## Copyright

Copyright Daniel Ma, Licensed MIT
