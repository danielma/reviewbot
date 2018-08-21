require 'spec_helper'

describe ReviewBot::PullRequest do
  before do
    WebMock.allow_net_connect!
    stub_request(:get, "https://api.github.com/repos/ministrycentered/reviewbot/pulls").
      to_return(status: 200, body: FakePullRequest.data.to_json, headers: {})
    stub_request(:get, "https://api.github.com/repos/ministrycentered/reviewbot/issues/3").
      to_return(status: 200, body: FakePullRequest.issues, headers: {})

    JSON.parse(ENV['CONFIG']).each do |app, app_config|
      @owner, @repo = app.split('/')
    end

    GH = Github.new(oauth_token: ENV['GH_AUTH_TOKEN'])
    binding.pry
    p = GH.pulls.list(@owner, @repo).body.first

    @pull = ReviewBot::PullRequest.new(p)
  end

  describe '#needs review' do
    it 'is true' do
      expect(@pull.needs_review?).to eq true
    end
  end

  it '#needs_first_review' do
    expect(@pull.needs_first_review?).to eq true
  end

  it '#reviewers' do
    expect(@pull.reviewers).to be_empty
  end
end

