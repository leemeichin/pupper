require 'pupper/api_associations'
require 'pupper/auditable'
require 'pupper/trackable_attributes'

module Pupper
  module Model
    extend ActiveSupport::Concern

    class NoSuchBackend < NameError; end

    included do
      include ActiveModel::Model
      include ActiveModel::Serializers::JSON

      include Pupper::Auditable
      include Pupper::TrackableAttributes
      include Pupper::ApiAssociations

      delegate :backend, to: :class

      def initialize(**args)
        args.slice!(*self.class._attributes)

        assocs, attrs = args.partition do |attr, value|
          attr.to_s =~ /_u?id$/ || value.is_a?(Hash) || value.is_a?(Array)
        end.map(&Hash.method(:[]))

        assocs = build_associations(assocs)

        super(**attrs, **assocs)

        changes_applied

        backend.register_model(self) unless backend == :none
      end

      def primary_key
        attributes.fetch(self.class.primary_key)
      end
    end

    class_methods do
      attr_writer :primary_key, :backend

      # @overload primary_key=(identifier)
      #   Set the identifier the including model will use by default
      #   when finding or updating (defaults to `:uid`)
      #
      #   == Parameters:
      #   identifier::
      #     A symbol refering to the identifying field in the model. e.g.
      #     `:id`.
      def primary_key
        @primary_key ||= :uid
      end

      # @overload backend=(class_or_symbol)
      #   Declare whether or not the model has a corresponding API client or not.
      #   (default: including class, plural, + client, e.g. `Form` => `FormsClient`)
      #
      #   == Parameters:
      #   class_or_symbol::
      #     `:none` if the model has no API, constant otherwise.
      def backend
        @backend ||= "#{model_name.name.pluralize}Client".constantize.new
      end
    end

    def to_json(*)
      attributes.except(*excluded_attrs).to_json
    end
  end
end
