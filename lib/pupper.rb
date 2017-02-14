require 'active_support/all'
require 'active_model'
require 'faraday'
require 'faraday_middleware'
require 'oj'
require 'typhoeus/adapters/faraday'

require 'pupper/version'
require 'pupper/backend'
require 'pupper/model'

module Pupper

  mattr_accessor :config

  # Changes some of Pupper's underlying assumptions
  # such as the name of the ActiveRecord model used for auditing
  # and the user agent passed into Faraday/Typhoeus
  #
  # @yield [self.config] The Pupper::Config instance
  def self.configure
    self.config ||= Config.new
    yield self.config
  end

  class Config
    attr_accessor :audit_with, :user_agent
    thread_mattr_accessor :current_user

    def initialize
      @audit_with = :audit_log
      @user_agent = "pupper (v: #{Pupper::VERSION})"
    end
  end
end
