require 'json'
require 'github_api'
require 'rest-client'
require 'timezone'
require 'time'

GH             = Github.new(oauth_token: ENV['GH_AUTH_TOKEN'])
OWNER          = ENV['OWNER']
SLACK_TOKEN    = ENV['SLACK_TOKEN']
SLACK_BOT_NAME = 'reviewbot'
SLACK_BOT_ICON = ':sleuth_or_spy:'
TIMEZONE       = ENV['TIMEZONE']
CONFIG         = JSON.parse(ENV['CONFIG'])
THUMB_REGEX    = /:[-\+]1:|^[-\+]1|\u{1F44D}|\u{1F44E}/

def get_reviews(owner, repo, number)
  # github_api doesn't support this yet
  conn = Faraday.new(
    url: 'https://api.github.com',
    headers: { Accept: 'application/vnd.github.black-cat-preview+json' }
  )
  JSON.parse(conn.get("/repos/#{owner}/#{repo}/pulls/#{number}/reviews?access_token=#{ENV['GH_AUTH_TOKEN']}").body)
end

desc 'Send reminders to team members to review PRs'
task :remind do
  CONFIG.each do |app, app_config|
    puts app

    time = Timezone[TIMEZONE].utc_to_local(Time.now)
    unless app_config['days'].include?(time.wday)
      puts "Day #{time.wday} is not in #{app_config['days']}. Skipping this app."
      next
    end
    unless app_config['hours'].include?(time.hour)
      puts "Hour #{time.hour} is not in #{app_config['hours']}. Skipping this app."
      next
    end

    notifications = GH.pulls.list(OWNER, app).body.each_with_object({}) do |pr, by_user|
      print '.'
      labels = GH.issues.get(OWNER, app, pr.number).labels.map(&:name)
      next if labels.include?('NOT READY')
      next if labels.include?('Blocked')
      next if labels.include?('+2')

      comments = GH.issues.comments.list(OWNER, app, number: pr.number).body.map do |comment|
        {
          user: comment.user.login,
          comment: comment.body
        }
      end
      reviewers = comments.select { |c| c[:comment] =~ THUMB_REGEX }.map { |c| c[:user] }
      reviewers += get_reviews(OWNER, app, pr.number).map { |r| r['user']['login'] }

      assignees = pr.assignee ? [pr.assignee.login] : []
      candidates = app_config['reviewers'].keys - assignees - reviewers

      candidates.each do |candidate|
        by_user[candidate] ||= []
        by_user[candidate] << pr.html_url
      end
    end

    puts

    notifications.each do |user, links|
      next unless (slack_username = app_config['reviewers'][user])
      RestClient.post(
        'https://slack.com/api/chat.postMessage',
        token: SLACK_TOKEN,
        channel: "@#{slack_username}",
        text: "Please review:\n#{links.join("\n")}",
        pretty: 1,
        icon_emoji: SLACK_BOT_ICON,
        username: SLACK_BOT_NAME
      )
      puts "sent #{links.size} to @#{slack_username}"
    end

    puts
  end
end
