# frozen_string_literal: true
module ReviewBot
  class Notification
    def initialize(pull_request:, suggested_reviewers:)
      @pull_request = pull_request
      @suggested_reviewers = suggested_reviewers
    end

    attr_reader :pull_request, :suggested_reviewers

    def message
      [needs_review_from, pull_request.html_url].join("\n")
    end

    private

    def needs_review_from
      [
        %("#{pull_request.title}" needs a #{needed_review_type} from),
        suggested_reviewers.map(&:slack_emoji).join(' ')
      ].join(' ')
    end

    def needed_review_type
      pull_request.needs_first_review? ? 'first review' : 'second review'
    end
  end
end
