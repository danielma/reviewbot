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

    allow_any_instance_of(Github::Client::PullRequests).to receive(:list).and_wrap_original do |m, *args|
      VCR.use_cassette('pull_requests') do
        m.call(*args)
      end
    end

    allow_any_instance_of(Github::Client::Issues).to receive(:get).and_wrap_original do |m, *args|
      VCR.use_cassette('issues') do
        m.call(*args)
      end
    end

    allow_any_instance_of(Github::Client::PullRequests::Reviews).to receive(:list).and_wrap_original do |m, *args|
      VCR.use_cassette('reviews') do
        m.call(*args)
      end
    end

    pull_requests = GH.pulls.list(@owner, @repo).body

    @pull = ReviewBot::PullRequest.new(pull_requests.last)
  end

  describe '#needs_review' do
    it 'is true' do
      expect(@pull.needs_review?).to eq false
    end
  end
end

