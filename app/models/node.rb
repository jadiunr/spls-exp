class Node

  class << self
    def create!(uuid, parent_uuid, children_uuid, relayable)
      {
        "uuid" => uuid,
        "parent_uuid" => parent_uuid,
        "children_uuid" => children_uuid,
        "relayable" => relayable
      }
    end
  end
end