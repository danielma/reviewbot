# Pull Request Review Reminder Bot

![Example Slack Message](https://raw.github.com/danielma/reviewbot/master/docs/images/slack-example.png)

Our team wants to be reminded via Slack about pending pull requests so we can have timely reviews and keep code moving through to production. There are two approaches with this bot: 

1. Set the bot to run at specific times (say, 10am and 3pm every day) and notify of all open Pull Requests.
1. Set the bot to run in intervals (say, every hour), only alerting the channels when a PR has been sitting idle for a certain number of person-hours. This means the bot is noiser during hours when everyone is working, and quiets down as people end their day.

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

There are two main strategies for using the reviewbot. If you want to run it at specific times and get notified about _all_ open pull requests, set `hours_to_review` to `0`. If you want to run the bot throughout the day and get notified about idle pull requests, set `hours_to_review` to a non-zero value.

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
    "hours_to_review": 6,
    "work_days": [1, 2, 3, 4, 5]
  }
}
```

#### Configuration keys

##### App

| Key | Description | Required | Default |
| --- | --- | --- | --- |
| `room` | The slack room for reviewbot to post notifications in. This will usually start with a `#`. | Yes | _(none)_ |
| `bamboohr_subdomain` | The Bamboo HR subdomain for your organization. This is required for any integration with Bamboo HR to work. | No | _(none)_ |
| `hours_to_review` | How many person-hours reviewbot should wait before sending a reminder about an idle pull request. For more info, look at the [FAQ](#faq) | Yes | _(none)_ |
| `work_days` | An array of weekdays that the reviewbot should consider work days. `0` is Sunday. | No | `[1,2,3,4,5]` |

##### Reviewer

| Key | Description | Required | Default |
| --- | --- | --- | --- |
| `github` | The reviewer's github login. | Yes | _(none)_ |
| `slack` | The reviewer's slack login. Reviewbot specifically surrounds this login in `:` characters to display that reviewer's custom emoji. | Yes | _(none)_ |
| `bamboohr` | The reviewer's ID in your Bamboo HR organization. | No | _(none)_ |
| `timezone` | The reviewer's timezone. | Yes | _(none)_ |

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

## FAQ

### What is a person-hour?

A _person-hour_ is a single hour worth of work from one person. It's used to measure the amount of time that a group of people is working. For example, a 4 person team does 16 person-hours worth of work in the time it takes a clock to advance 4 hours. It's explained well [in the wikipedia article](https://en.wikipedia.org/wiki/Person-hour).

### How should I set my `hours_to_review`?

My general formula is


```
(number of developers - 1) * (clock hours)
```

On a 4 person team where you don't want PRs sitting idle for more than 2 hours, this means setting `hours_to_review` to `6`.

## Copyright

Copyright Daniel Ma, Licensed MIT
