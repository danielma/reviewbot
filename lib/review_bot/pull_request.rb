# frozen_string_literal: true
module ReviewBot
  class PullRequest < SimpleDelegator
    attr_reader :ignore_in_progress
    alias ignore_in_progress? ignore_in_progress

    def initialize(pull_request, options = {})
      super(pull_request)

      @ignore_in_progress = options[:ignore_in_progress] || false
    end

    def needs_review?
      !approved? && !blocked? && !review_in_progress?
    end

    def needs_first_review?
      needs_review? && reviewers.count.zero?
    end

    def reviewers
      reviews_from_other_humans
        .map { |r| r.user.login }
        .uniq
    end

    def last_touched_at
      if last_touch
        Time.parse(last_touch.created_at)
      else
        Time.parse(created_at)
      end
    end

    def repo_owner
      base.repo.owner.login
    end

    def repo_name
      base.repo.name
    end

    def inspect
      "GithubPullRequest##{number} ( " +
        [
          "approved: #{approved?}",
          "blocked: #{blocked?}",
          "last touched: #{last_touched_at}",
          "review_in_progress: #{review_in_progress?}",
          "needs_review: #{needs_review?}",
          "url: #{html_url}"
        ].join(', ') +
        ' )'
    end

    private

    def approved?
      if ez?
        approvals_count > 0
      else
        approvals_count > 1
      end
    end

    def ez?
      labels.include?('ez')
    end

    def blocked?
      labels.include?('not ready') || labels.include?('blocked')
    end

    def review_in_progress?
      return false if ignore_in_progress?

      case reviewers.length
      when 0
        false
      when 1
        approvals_count != 1
      else
        !approved?
      end
    end

    def last_touch
      @last_touch ||= reviews_from_other_humans
                      .sort_by(&:created_at)
                      .last
    end

    def labels
      @labels ||= issue.labels.map(&:name).map(&:downcase)
    end

    def issue
      @issue ||= GH.issues.get(repo_owner, repo_name, number)
    end

    def reviews
      @reviews ||= PullRequestReview.for_pull_request(self)
    end

    def reviews_from_humans
      reviews.reject { |r| r.user.login.include?('-bot') }
    end

    def reviews_from_other_humans
      reviews_from_humans.select do |r|
        r.user.login != user.login && ignore_in_progress? ? r.approved? : true
      end
    end

    def approvals_count
      reviews_from_other_humans
        .select(&:approved?)
        .map { |r| r.user.login }
        .uniq
        .count
    end
  end
end
