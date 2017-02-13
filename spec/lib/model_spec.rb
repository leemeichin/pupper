require 'spec_helper'

RSpec.describe Pupper::Model, 'integration of ApiModel into subclasses' do
  let(:test_user) do
    stub_const 'TestUser', (Class.new do
      include Pupper::Model
      attr_accessor :uid, :name
      audit :call_me_maybe

      def call_me_maybe
        self.name = 'Maybe!'
      end
    end)
  end

  let(:uid) { 123 }
  let(:original_name) { 'Nimda McAdminFace' }
  let(:new_name) { 'Phoenix McEagleFace' }
  let(:error_name) { 'Error McWarningFace' }

  subject { test_user.new(uid: uid, name: original_name) }

  before do
    test_user.backend = double
    allow(test_user.backend).to receive(:update).with(test_user)
    allow(test_user.backend).to receive(:register_model).with(test_user)
  end

  describe 'the available instance methods' do
    it { is_expected.to respond_to :update_attributes }
    it { is_expected.to respond_to :audit_logs }
    it { is_expected.to respond_to :to_json }
    it { is_expected.to respond_to :attributes }
    it { is_expected.to respond_to :reload! }
    it { is_expected.to respond_to :rollback! }
  end

  describe 'building with attributes' do
    it 'stores the attributes in an underlying hash' do
      expect(subject.attributes).to eq(uid: uid, name: original_name)
    end

    it 'marks the model as unchanged' do
      expect(subject).not_to be_changed
    end
  end

  describe 'logging changes in the model' do
    let(:audit_log) { subject.audit_logs.first }

    let(:change_attrs) do
      {
        user: Pupper.config.current_user,
        auditable_type: 'TestUser',
        what_changed: { name: [original_name, new_name] }
      }
    end

    it 'creates an audit log when updating' do
      subject.update_attributes(name: new_name)
      expect(audit_log).to have_attributes(change_attrs)
    end

    it 'creates no audit log when updating fails' do
      expect do
        subject.update(name: error_name) do
          raise StandardError
        end
      end.to raise_error(StandardError).and.not_to receive(:create_audit_log)
    end
  end

  describe 'adding custom auditing' do
    it 'creates an audit log for a custom auditable method' do
      expect(subject).to receive(:create_audit_log)
      subject.call_me_maybe
    end
  end
end
