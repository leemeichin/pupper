module Pupper
  module ApiAssociations
    extend ActiveSupport::Concern

    class_methods do
      def associations
        @associations ||= { has_one: [], has_many: [] }
      end

      def has_one(*assocs)
        associations[:has_one].concat(assocs)
      end

      def has_many(*assocs)
        associations[:has_many].concat(assocs)
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
        excluded_attrs << name if foreign_key.present?

        name = foreign_key.present? ? "#{name}_#{foreign_key}" : name
        send("#{name}=", value)
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
        model = "#{self.class.parent}/#{name.to_s.singularize}".classify.constantize
        values.map(&model.method(:new))
      end

      def create_assoc_model(assocs, name, foreign_key, value)
        case find_assoc_type(name)
        when :has_one
          assocs[name] = create_has_one_assoc_model(name, foreign_key, value)
        when :has_many
          assocs[name] = create_has_many_assoc_model(name, value)
        else
          assocs[:"#{name}_#{foreign_key}"] = value
        end
      end

      def excluded_attrs
        @excluded_attrs ||= []
      end
    end
  end
end
