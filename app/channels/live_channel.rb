class LiveChannel < ApplicationCable::Channel
  def subscribed
    @root_unique_name = params[:unique_name]
    stream_from "live_#{params[:unique_name]}"
    stream_from uuid
    if current_user.present?
      if @root_unique_name == current_user.unique_name
        stream_from @root_unique_name
      end
    end
  end

  def unsubscribed
    destroy_tree if @root_unique_name == current_user.unique_name
  end

  def be_root
    tree = [Node.create!(uuid, nil, [], true)]
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
    tree << Node.create!(uuid, data["parent_uuid"], data["children_uuid"], true)
    parent = tree.find { |node| node["uuid"] == data["parent_uuid"] }
    parent["children_uuid"] << uuid
    rset(@root_unique_name, tree)
    [uuid, data["parent_uuid"]].each {|uuid| ActionCable.server.broadcast(
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

  # perform("signaling", { sendto: "id", data: "signaling_data" })
  def emit_to(data)
    ActionCable.server.broadcast(
      data["sendto"],
      method: data["method"],
      from_uuid: uuid,
      message: data["message"]
    )
  end

  # perform("comment", { comment: "message" })
  def comment(data)
    name = current_user.unique_name || "Guest"
    ActionCable.server.broadcast(
      "live_#{@root_unique_name}",
      method: "comment",
      name: name,
      comment: data["comment"]
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
