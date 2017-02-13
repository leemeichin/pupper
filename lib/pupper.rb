require 'pupper/version'
require 'pupper/backend'
require 'pupper/model'

module Pupper

  mattr_accessor :config

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
