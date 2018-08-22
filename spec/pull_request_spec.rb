require 'spec_helper'

describe ReviewBot::PullRequest do
  before do
    JSON.parse(ENV['CONFIG']).each do |app, app_config|
      @owner, @repo = app.split('/')
    end

    GH = Github.new(oauth_token: ENV['GH_AUTH_TOKEN'])
    binding.pry
    p = GH.pulls.list(@owner, @repo).body.first

    @pull = ReviewBot::PullRequest.new(p)
  end

    VCR.use_cassette('pull_requests') do
      @p = GH.pulls.list(@owner, @repo).body.first
    end

    @pull = ReviewBot::PullRequest.new(@p)
  end

  it 'thing' do
    VCR.use_cassette('issues') do
      expect(@pull.needs_review?).to eq true
    end
  end
end

