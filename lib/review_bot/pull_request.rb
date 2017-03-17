module ReviewBot
  class PullRequest < SimpleDelegator
    def needs_review?
      !approved? && !blocked? && !review_in_progress?
    end

    def needs_first_review?
      needs_review? && reviewers.count == 0
    end

    def reviewers
      [comments_from_other_humans, reviews_from_other_humans].flatten.
        map { |i| i['user']['login'] }.
        uniq
    end

    def last_touched_at
      if last_touch
        Time.parse(last_touch['created_at'] || last_touch['submitted_at'])
      else
        Time.parse(created_at)
      end
    end

    def inspect
      "GithubPullRequest##{number} ( " +
        [
          "approved: #{approved?}",
          "blocked: #{blocked?}",
          "last touched: #{last_touched_at}",
          "review_in_progress: #{review_in_progress?}",
          "needs_review: #{needs_review?}",
          "url: #{html_url}",
        ].join(", ") +
        " )"
    end

    private

    def approved?
      labels.include?('+2')
    end

    def blocked?
      labels.include?('not ready') || labels.include?('blocked')
    end

    def review_in_progress?
      case reviewers.length
      when 0
        false
      when 1
        !labels.include?('+1')
      else
        !approved?
      end
    end

    def last_touch
      @last_touch ||= [comments_from_other_humans, reviews_from_other_humans].flatten.
                        sort_by { |comment_or_review| comment_or_review['created_at'] || comment_or_review['submitted_at'] }.
                        last
    end

    def repo_owner
      base.repo.owner.login
    end

    def repo_name
      base.repo.name
    end

    def labels
      @labels ||= issue.labels.map(&:name).map(&:downcase)
    end

    def issue
      @issue ||= GH.issues.get(repo_owner, repo_name, number)
    end

    def comments
      @comments ||= GH.issues.comments.list(repo_owner, repo_name, number: number).body
    end

    def comments_from_humans
      comments.reject { |c| c.user.login.include?('-bot') }
    end

    def comments_from_other_humans
      comments_from_humans.select { |c| c.user.login != user.login }
    end

    def reviews
      # github_api doesn't support this yet
      @reviews ||= (
        conn = Faraday.new(
          url: 'https://api.github.com',
          headers: { Accept: 'application/vnd.github.black-cat-preview+json' }
        )
        JSON.parse(conn.get("/repos/#{repo_owner}/#{repo_name}/pulls/#{number}/reviews?access_token=#{ENV['GH_AUTH_TOKEN']}").body)
      )
    end

    def reviews_from_humans
      reviews.reject { |r| r['user']['login'].include?('-bot') }
    end

    def reviews_from_other_humans
      reviews_from_humans.select { |r| r['user']['login'] != user.login }
    end
  end
end
