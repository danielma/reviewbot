# Pull Request Review Reminder Bot

![Example Slack Message](https://raw.github.com/danielma/reviewbot/master/docs/images/slack-example.png)

Our team wants to be reminded via Slack about pending pull requests so we can have timely reviews and keep code moving through to production. There are two approaches with this bot: 

1. Set the bot to run at specific times (say, 10am and 3pm every day).
1. Set the bot to run in intervals (say, every hour), only alerting the channels when a PR has been sitting idle for a certain number of collective working hours. This means the bot is noiser during hours when everyone is working, and quiets down as people end their day.

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

There is optional support for bambooHR to determine who is out on any given day, and to not include them in consideration for who is available to review PRs

##### Example Config

```json
{
  "danielma/reviewbot": {
    "room": "#reviewbot",
    "bamboohr_subdomain": "mycompany",
    "reviewers": [
      {
        "github": "danielma",
        "slack": "dma",
        "bamboohr": 1,
        "timezone": "America/Los_Angeles"
      },
      {
        "github": "contributor",
        "slack": "dmas_evil_twin",
        "bamboohr": 2,
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
  BAMBOOHR_API_KEY=1234 \
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
