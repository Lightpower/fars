ENV['RACK_ENV'] = ENV['RAILS_ENV'] = 'test'

require File.dirname(__FILE__) + '/../app/application'

require 'rack/test'
require 'database_cleaner'
require 'rspec'
require 'shoulda'

FakeWeb.allow_net_connect = false

FactoryGirl.find_definitions

Dir["#{File.dirname(__FILE__)}/support/*.rb"].sort.each { |f| require f}
