class AssocVal
  include Pupper::Model
  self.backend = :none
  attr_accessor :a
end