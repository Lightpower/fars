require 'rspec'
require 'shoulda'
require 'database_cleaner'
require 'pry'

require 'fars'

require 'yaml'
require 'active_record'

RSpec.configure do |config|
  config.color_enabled = true

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
  end

  config.after(:suite) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end

root      = File.dirname(__FILE__)
db_config = YAML.load_file("#{root}/config/database.yml")
ActiveRecord::Base.establish_connection(db_config)
