require 'oplog_event_handler'
require 'rspec/autorun'

RSpec.configure do |config|
  config.color     = true
  config.fail_fast = true
  config.formatter = 'documentation'
end