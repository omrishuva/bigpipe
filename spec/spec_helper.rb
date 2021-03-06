ENV["RAILS_ENV"] = "test"

require File.expand_path("../../config/environment", __FILE__)
require "rspec/rails"
require "capybara/rails"
require "rack/test"
require 'pry'

RSpec.configure do |config|
  config.use_transactional_fixtures = true

  config.infer_spec_type_from_file_location!

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
  	mocks.syntax = :should
	end

end

