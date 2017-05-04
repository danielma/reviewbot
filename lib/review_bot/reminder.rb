# frozen_string_literal: true
module ReviewBot
  GH = Github.new(oauth_token: ENV['GH_AUTH_TOKEN'])

  class Reminder
    attr_reader :owner, :repo, :app_config

    def initialize(owner, repo, app_config)
      @owner = owner
      @repo = repo
      @app_config = app_config
    end

    def message
      return if notifications.empty?

      # :smile_cat: https://github.com/danielma/reviewbot/pull/3 needs a first review from :dma: :dmas_evil_twin:
      message_header = ":smile_cat: :wave:\n"
      message_header + notifications.map(&:message).join("\n\n")
    end

    def app_reviewers
      @app_reviewers ||= app_config['reviewers'].map { |r| Reviewer.new(r) }
    end

    def notifications
      @notifications ||= potential_notifications.compact
    end

    def potential_notifications
      GH.pulls.list(owner, repo).body.map do |p|
        pull = PullRequest.new(p)

        print '.'

        next unless pull.needs_review?

        potential_reviewers = app_reviewers.reject { |r| r.github == pull.user.login }

        work_hours_since_last_touch = potential_reviewers.map do |reviewer|
          reviewer.work_hours_between(pull.last_touched_at, Time.now.utc)
        end.reduce(:+)

        next if work_hours_since_last_touch < app_config['hours_to_review']

        suggested_reviewers = potential_reviewers.reject do |reviewer|
          pull.reviewers.include?(reviewer['github'])
        end

        next if suggested_reviewers.empty?

        Notification.new(
          pull_request: pull,
          suggested_reviewers: suggested_reviewers
        )
      end
    end
  end
end
