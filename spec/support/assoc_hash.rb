class AssocHash
  include Pupper::Model
  self.backend = :none
  attr_accessor :a, :b, :c
end
