require 'pupper/parse_json'

module Pupper
  class Backend
    class BaseUrlNotDefined < StandardError; end

    attr_reader :client, :model

    delegate :base_url, to: :class

    class << self
      attr_writer :base_url

      def base_url
        if @base_url.nil?
          raise BaseUrlNotDefined, <<-ERR
            Add the following to #{name} to make it work:

              self.base_url = "https://example.com/some/path"

            Making sure to change the URL to something useful :)))
          ERR
        end

        @base_url
      end
    end

    %i(get put post delete patch).each do |name|
      class_eval <<-RB.strip_heredoc, __FILE__, __LINE__
        def #{name}(*args)
          client.send(:#{name}, *args).body
        end
      RB
    end

    def initialize
      @client = Faraday.new(base_url, ssl: { verify: Rails.env.production? }) do |builder|
        builder.request :json
        builder.use Pupper::ParseJson
        builder.response :logger if Rails.env.development?
        builder.response :raise_error
        builder.adapter :typhoeus
        builder.headers['User-Agent'] = Pupper.config.user_agent
      end
    end

    def register_model(model)
      @model = model
    end
  end
end
