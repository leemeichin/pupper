class Assoc
  include Pupper::Model
  self.backend = :none
  attr_accessor :id
end
