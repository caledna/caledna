# frozen_string_literal: true

require 'spec_helper'
require 'pundit/rspec'
require 'vcr'

ENV['RAILS_ENV'] ||= 'test'

require File.expand_path('../config/environment', __dir__)

# Prevent database truncation if the environment is production
abort('The Rails is running in production mode!') if Rails.env.production?

require 'rspec/rails'

# Checks for pending migrations and applies them before tests are run.
ActiveRecord::Migration.maintain_test_schema!

Dir[Rails.root.join('spec/support/**/*.rb')].sort.each { |file| require file }

RSpec.configure do |config|
  config.include Warden::Test::Helpers
  # run each of your examples within a transaction
  config.use_transactional_fixtures = true
  # mix in different behaviours to your tests based on their file location.
  config.infer_spec_type_from_file_location!
  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include ControllerHelpers, type: :controller
  config.include ValidUserRequestHelper, type: :request
  config.include ValidUserRequestHelper, type: :feature
  config.include FactoryBot::Syntax::Methods
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

VCR.configure do |config|
  config.cassette_library_dir = 'fixtures/vcr_cassettes'
  # config.allow_http_connections_when_no_cassette = true
  config.hook_into :webmock
end
