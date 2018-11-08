class Node
  include ActiveModel::Validations

  attr_accessor :uuid, :parent_uuid, :children_uuid, :relayable

  class << self
    def create!(uuid, parent_uuid, children_uuid, relayable)
      new(uuid, parent_uuid, children_uuid, relayable)
    end
  end

  def initialize(uuid, parent_uuid, children_uuid, relayable)
    self.uuid = uuid
    self.parent_uuid = parent_uuid
    self.children_uuid = children_uuid
    self.relayable = relayable
  end
end