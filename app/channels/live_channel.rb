class LiveChannel < ApplicationCable::Channel
  def subscribed
    @root_unique_name = params[:unique_name]
    stream_from "live_#{params[:unique_name]}"
    stream_from uuid
    if current_user.present? and @root_unique_name == current_user.unique_name
      stream_from @root_unique_name
    end
  end

  def unsubscribed
    if current_user.present? and @root_unique_name == current_user.unique_name
      destroy_tree
    end

    delete_node(uuid)

    ActionCable.server.broadcast(
      "live_#{@root_unique_name}",
      from_uuid: uuid,
      method: "disconnected"
    )
  end

  def get_uuid
    ActionCable.server.broadcast(
      uuid,
      method: "get_uuid",
      uuid: uuid
    )
  end

  def be_root
    tree = {}
    tree[uuid] = {
      parent_uuid: nil,
      children_uuid: [],
      relayable: true
    }
    rset(@root_unique_name, tree)
  end

  def destroy_tree
    rdel(@root_unique_name)
    puts "#{@root_unique_name} Live Channel Deleted"
  end

  def get_node_tree
    tree = rget(@root_unique_name)
    ActionCable.server.broadcast(
      uuid,
      method: "get_node_tree",
      tree: tree
    )
  end

  def add_node_to_tree(data)
    tree = rget(@root_unique_name)
    tree[uuid] = {
      parent_uuid: data["parent_uuid"],
      children_uuid: data["children_uuid"],
      relayable: true
    }
    parent = tree[data["parent_uuid"]]
    parent["children_uuid"] << uuid
    rset(@root_unique_name, tree)
    [uuid, data["parent_uuid"]].each {|uuid| ActionCable.server.broadcast(
      uuid,
      method: "add_node_to_tree",
      tree: tree
    )}
  end

  def emit_to(data)
    ActionCable.server.broadcast(
      data["sendto"],
      method: data["method"],
      from_uuid: uuid,
      message: data["message"]
    )
  end

  private
    def rget(key)
      JSON.parse(REDIS.get(key))
    end

    def rset(key, value)
      REDIS.set(key, value.to_json)
    end

    def rdel(key)
      REDIS.del(key)
    end

    def delete_node(id)
      tree = rget(@root_unique_name)
      deleting_node = tree[id]
      tree.delete(id)
      parent = tree[deleting_node["parent_uuid"]]
      parent["children_uuid"].delete(id)
      lost_children = tree[deleting_node["children_uuid"]] || []
      lost_children.each {|node| node["parent_uuid"] = nil} unless lost_children == []
      rset(@root_unique_name, tree)
    end
end
