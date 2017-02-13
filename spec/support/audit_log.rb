class AuditLog
  attr_accessor :user, :auditable_type, :auditable_id, :what_changed

  def self.create(*)
    nil # do nothing
  end

  def self.where(*)
    [] # do nothing
  end
end
