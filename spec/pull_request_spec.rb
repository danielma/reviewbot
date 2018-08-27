require 'spec_helper'

describe ReviewBot::PullRequest do
  before do
    JSON.parse(config).each do |app, app_config|
      @owner, @repo = app.split('/')
      @app_config = app_config
    end

    GH = Github.new(oauth_token: ENV['GH_AUTH_TOKEN'])

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

    @pull = ReviewBot::PullRequest.new(pull_requests.last, { notify_in_progress_reviewers: @app_config['notify_in_progress_reviewers'] })
  end

  describe '#needs_review' do
    context 'Pull request has two reviewer who have made comments, but no approvals' do
      context 'ignore in progress is false' do
        let(:config) { {'ministrycentered/reviewbot': { 'notify_in_progress_reviewers': false }}.to_json }

        it 'is true' do
          expect(@pull.needs_review?).to eq false
        end
      end

      context 'ignore in progress is true' do
        let(:config) { {'ministrycentered/reviewbot': { 'notify_in_progress_reviewers': true }}.to_json }

        it 'is true' do
          expect(@pull.needs_review?).to eq true
        end
      end
    end
  end
end
