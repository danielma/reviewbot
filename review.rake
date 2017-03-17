require 'json'

CONFIG = JSON.parse(ENV['CONFIG'])
SLACK_TOKEN    = ENV['SLACK_TOKEN']
SLACK_BOT_NAME = 'reviewbot'
SLACK_BOT_ICON = ':smile_cat:'

require_relative 'lib/review_bot'

desc 'Send reminders to team members to review PRs'
task :remind, [:mode] do |_t, args|
  dry_run = args[:mode] == "dry"

  puts "-- DRY RUN --\n\n" if dry_run

  CONFIG.each do |app, app_config|
    owner, repo = app.split("/")
    room = app_config['room']

    puts "#{owner}/#{repo}"

    message = ReviewBot::Reminder.new(owner, repo, app_config).message

    puts

    next if message.nil?

    if dry_run
      puts "Would deliver message to #{room}"
      puts message
      puts
    else
      puts "Delivering a message to #{room}"

      RestClient.post(
        'https://slack.com/api/chat.postMessage',
        token: SLACK_TOKEN,
        channel: room,
        text: message,
        icon_emoji: SLACK_BOT_ICON,
        username: SLACK_BOT_NAME,
      )
    end
  end
end
