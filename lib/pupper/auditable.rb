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

      def audit_action(*methods)
        underlying_methods = ''

        methods.each do |meth|
          underlying_methods << <<-RB.strip_heredoc
            def #{meth}
              begin
                super
              rescue Exception => e
                log_action_failure('#{meth}', e)
                throw e
              end
              log_action '#{meth}'
            end
          RB
        end

        prepend Module.new { module_eval(underlying_methods, __FILE__, __LINE__) }
      end
    end

    included do
      extend ActiveModel::Callbacks

      define_model_callbacks :update, only: :around
      around_update :log_update

      def audit(&block)
        run_callbacks :update, &block
        changes_applied
      end

      def audit_logs
        audit_model.where(auditable_type: model_name.name, auditable_id: primary_key)
      end

      def log_update
        begin
          yield
        rescue Exception => e
          create_audit_log('update', e)
          throw e
        end
        create_audit_log 'update'
      end

      def create_audit_log(action, e = nil)
        return unless changed?

        audit_model.create(
          action: action,
          auditable_type: model_name.name,
          auditable_id: primary_key,
          user: Pupper.config.current_user,
          what_changed: changes,
          success: e.nil?,
          exception: e
        )
      end

      def log_action(action, changes = nil, e = nil)
        audit_model.create(
          action: action,
          auditable_type: model_name.name,
          auditable_id: primary_key,
          user: Pupper.config.current_user,
          what_changed: changes,
          success: e.nil?,
          exception: e
        )
      end

      def update_attributes(attrs)
        resp = {}
        run_callbacks(:update) do
          assign_attributes(attrs)
          resp = backend.update
        end

        changes_applied
        resp
      end

      private

      def audit_model
        @audit_model ||= Pupper.config.audit_with.to_s.classify.constantize
      end
    end
  end
end
