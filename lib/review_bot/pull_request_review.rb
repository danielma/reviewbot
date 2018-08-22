module ReviewBot
  class PullRequestReview < Hashie::Mash
    def self.for_pull_request(pull_request)
      reviews = GH.pull_requests
                  .reviews
                  .list(pull_request.repo_owner, pull_request.repo_name, pull_request.number)

      reviews.map { |r| new r }
    end

    def approved?
      state == 'APPROVED'
    end

    def created_at
      submitted_at
    end
  end
end
