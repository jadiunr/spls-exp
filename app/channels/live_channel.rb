class LiveChannel < ApplicationCable::Channel
  def subscribed
    stream_from "live_#{params[:unique_name]}"
  end

  def unsubscribed
    destroy_tree if @root.unique_name == current_user.unique_name
  end

  def be_root
    tree = [Node.create!(uuid, nil, [], true)].to_json
    @root = current_user
    REDIS.set(current_user.unique_name, tree)
  end

  def destroy_tree
    REDIS.del(current_user.unique_name)
  end

  def get_node_tree
    tree = REDIS.get(@root.unique_name)
    LiveChannel.broadcast_to(uuid, tree)
  end

  def add_node_to_tree(parent_uuid, children_uuid)
    tree = REDIS.get(@root.unique_name)
    tree << Node.create!(uuid, parent_uuid, children_uuid, true)
    parent = tree.find { |node| node.uuid == parent_uuid }
    parent.children_uuid = uuid
    REDIS.set(@root.unique_name, tree)
  end

  def child_disconnect_notify(dc_child_uuid)
    tree = REDIS.get(@root.unique_name)
    tree.delete_if {|node| node.uuid == dc_child_uuid}
    lost_children = tree.select {|node| node.parent_uuid == dc_child_uuid}
    lost_children.each {|node| node.parent_uuid = nil}
    REDIS.set(@root.unique_name, tree)

    LiveChannel.broadcast_to(uuid, tree)
    lost_children.each {|lost_child| LiveChannel.broadcast_to(lost_child.uuid, tree)}
  end

  def direct_message(to_uuid, data)
    LiveChannel.broadcast_to(to_uuid, data)
  end

  def speak(data)
    name = current_user.unique_name || "Guest"
    ActionCable.server.broadcast("live_#{@root.unique_name}", {name: name, data: data})
  end
end
