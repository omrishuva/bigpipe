require File.expand_path("../boot", __FILE__)

require "rails"

# Pick the frameworks you want:
require "active_model/railtie"
require "action_controller/railtie"
require "action_view/railtie"
require "sprockets/railtie"
require "action_mailer/railtie"
require 'bootstrap'
require 'bcrypt'


# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Play
  class Application < Rails::Application
  	config.autoload_paths += Dir["#{config.root}/lib/**/"]
  	config.autoload_paths += Dir["#{config.root}/app/jobs/**/"]
  	config.i18n.default_locale = :en
  	config.active_job.queue_adapter = :pub_sub_queue
  end
end
