require 'spec_helper'

RSpec.describe Pupper::ApiAssociations do

  context 'association dsl' do
    subject { ModelWithAssociations }

    it { is_expected.to respond_to(:has_one) }
    it { is_expected.to respond_to(:has_many) }
  end

  context 'building associations' do
    subject do
      ModelWithAssociations.new(
        assoc_vals: [{a: 1}, {a: 2}, {a: 3}],
        assoc_hash: {a: 1, b: 2, c: 3},
        assoc_id: 1,
        no_assoc_id: 2
      )
    end

    it 'should convert assoc_id to assoc, with the id as the value' do
      expect(subject.assoc).to be_an Assoc
      expect(subject.assoc).to have_attributes(id: subject.assoc_id)
    end

    it 'should not convert no_assoc_id at all' do
      expect(subject).not_to respond_to :no_assoc
      expect(subject.no_assoc_id).to be 2
    end

    it 'should convert assoc hash to a corresponding object' do
      expect(subject.assoc_hash).to be_an AssocHash
      expect(subject.assoc_hash).to have_attributes(a: 1, b: 2, c: 3)
    end

    it 'should convert assoc_arrays into a list of corresponding objects' do
      expect(subject.assoc_vals).to all be_an AssocVal
    end
  end
end
