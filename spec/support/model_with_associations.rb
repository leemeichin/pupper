class ModelWithAssociations
  include Pupper::Model

  self.backend = :none

  attr_accessor :assoc_arrays, :assoc_vals, :assoc_id, :no_assoc_id

  has_one :assoc_hash, :assoc
  has_many :assoc_vals
end
