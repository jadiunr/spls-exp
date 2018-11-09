class LiveChannel < ApplicationCable::Channel
  def subscribed
    @root_unique_name = params[:unique_name]
    stream_from "live_#{params[:unique_name]}"
    stream_from uuid
    stream_from @root_unique_name if @root_unique_name == current_user.unique_name
  end

  def unsubscribed
    destroy_tree if @root_unique_name == current_user.unique_name
  end

  def be_root
    tree = [Node.create!(@root_unique_name, nil, [], true)]
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

  def add_node_to_tree(parent_uuid, children_uuid)
    tree = rget(@root_unique_name)
    tree << Node.create!(uuid, parent_uuid, children_uuid, true)
    parent = tree.find { |node| node["uuid"] == parent_uuid }
    parent["children_uuid"] = uuid
    rset(@root_unique_name, tree)
    [uuid, parent_uuid].each {|uuid| ActionCable.server.broadcast(
      uuid,
      method: "add_node_to_tree",
      tree: tree
    )}
  end

  def child_disconnect_notify(dc_child_uuid)
    tree = rget(@root_unique_name)
    tree.delete_if {|node| node["uuid"] == dc_child_uuid}
    lost_children = tree.select {|node| node["parent_uuid"] == dc_child_uuid}
    lost_children.each {|node| node["parent_uuid"] = nil} unless lost_children == []
    rset(@root_unique_name, tree)

    ActionCable.server.broadcast(
      uuid,
      method: "child_disconnect_notify",
      tree: tree
    )
    lost_children.each {|lost_child| ActionCable.server.broadcast(
      lost_child["uuid"],
      method: "child_disconnect_notify",
      tree: tree
    )}
  end

  def signaling(sendto, data)
    ActionCable.server.broadcast(
      sendto,
      method: "signaling",
      data: data
    )
  end

  def comment(data)
    name = current_user.unique_name || "Guest"
    ActionCable.server.broadcast(
      "live_#{@root_unique_name}",
      method: "comment",
      name: name,
      comment: data
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
end
