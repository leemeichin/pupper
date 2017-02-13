module Pupper
  module Auditable
    extend ActiveSupport::Concern

    class_methods do
      def audit(*methods)
        underlying_methods = ''

        methods.each do |meth|
          underlying_methods << <<-RB.strip_heredoc
            def #{meth}
              audit { super }
              changes_applied
            end
          RB
        end

        prepend Module.new { module_eval(underlying_methods, __FILE__, __LINE__) }
      end
    end

    included do
      extend ActiveModel::Callbacks

      define_model_callbacks :update, only: :after
      after_update :create_audit_log

      def audit(&block)
        run_callbacks :update, &block
        changes_applied
      end

      def audit_logs
        AuditLog.where(auditable_type: model_name.name, auditable_id: primary_key)
      end

      def create_audit_log
        return unless changed?

        audit_model.create(
          auditable_type: model_name.name,
          auditable_id: primary_key,
          user: Pupper.config.current_user,
          what_changed: changes
        )
      end

      def update_attributes(**attrs)
        run_callbacks(:update) do
          assign_attributes(**attrs)
          backend.update(self)
        end

        changes_applied
      end

      private

      def audit_model
        @audit_model ||= Pupper.config.audit_with.to_s.classify.constantize
      end
    end
  end
end
