require 'bundler/setup'
require 'pupper'

require 'pry'
require 'byebug'

RSpec.configure do |config|
  Dir[File.expand_path('./support/**/*.rb', __dir__)].each { |f| require f }

  config.example_status_persistence_file_path = '.rspec_status'

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  Pupper.configure do |c|
    c.current_user = FakeUser.new(
      id: 1,
      name: 'Fakey McFakerson',
      email: 'fake@example.com'
    )
  end
end
