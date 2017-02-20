module Pupper
  module ApiAssociations
    extend ActiveSupport::Concern

    class_methods do
      def associations
        @associations ||= { has_one: [], has_many: [] }
      end

      def has_one(assoc)
        associations[:has_one] << assoc
      end

      def has_many(assoc)
        associations[:has_many] << assoc
      end
    end

    included do
      private

      delegate :associations, to: :class
      attr_reader :excluded_attrs

      def build_associations(assocs)
        assocs.each_with_object({}) do |(name, value), memo|
          name = name.to_s
          foreign_key = name.slice!(/_u?id/)&.[](1..-1)&.to_sym
          name = name.to_sym

          create_assoc_model(memo, name, foreign_key, value)
        end
      end

      def create_attribute(name, foreign_key = nil, value = nil)
        self.class.attr_accessor(name)

        if foreign_key.present?
          excluded_attrs << name
          send("#{name}_#{foreign_key}=", value)
        end
      end

      def find_assoc_type(name)
        associations
          .find { |(_, assoc)| assoc.include?(name) }&.first
      end

      def create_has_one_assoc_model(name, foreign_key, value)
        create_attribute(name, foreign_key, value)
        model = "#{self.class.parent}/#{name}".classify.constantize

        if foreign_key
          model.new(foreign_key => value)
        else
          model.new(value)
        end
      end

      def create_has_many_assoc_model(name, values)
        create_attribute(name)
        values.map(&name.constantize)
      end

      def create_assoc_model(assocs, name, foreign_key, value)
        case find_assoc_type(name)
        when :has_one
          assocs[name] = create_has_one_assoc_model(name, foreign_key, value)
        when :has_many
          assocs[name] = create_has_many_assoc_model(name, value)
        else
          Rails.logger.warn("Try to use an association for #{name} in #{model_name.name}!")
          assocs[:"#{name}_#{foreign_key}"] = value
        end
      end

      def excluded_attrs
        @excluded_attrs ||= []
      end
    end
  end
end
