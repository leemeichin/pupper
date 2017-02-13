module Pupper
  module TrackableAttributes
    def self.included(base)
      base.send :include, ActiveModel::Dirty
      base.send :include, InstanceMethods

      class << base
        prepend ClassMethods
      end
    end

    module InstanceMethods
      def attributes
        @attributes ||= {}
      end

      def reload!
        restore_attributes
      end

      def rollback!
        restore_attributes
      end

      def refresh(**attrs)
        assign_attributes(**attrs)
        changes_applied
      end
    end

    module ClassMethods
      def _attributes
        @_attributes ||= []
      end

      def _attributes=(attrs)
        @_attributes = attrs
      end

      def attr_accessor(*attrs)
        # override the default so that we can hook into the created methods
        define_attribute_methods(*attrs)

        _attributes << attrs

        attrs.each do |attr|
          define_method attr do
            attributes[attr]
          end

          define_method "#{attr}=" do |value|
            send("#{attr}_will_change!") unless value == send(attr)
            attributes[attr] = value
          end
        end
      end
    end
  end
end
