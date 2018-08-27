require 'spec_helper'

describe ReviewBot::Reminder do
  before do
    JSON.parse(ENV['CONFIG']).each do |app, app_config|
      owner, repo = app.split('/')

      puts "#{owner}/#{repo}"

      ReviewBot::HourOfDay.work_days = app_config['work_days']

      @reminder = ReviewBot::Reminder.new(owner, repo, app_config)
    end
  end

  it 'returns a reminder' do
    expect(@reminder).to be_a ReviewBot::Reminder
  end
end
