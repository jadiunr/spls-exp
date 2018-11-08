class StreamingSessionChannel < ApplicationCable::Channel
  def subscribed
    stream_from "session_#{params[:session_id]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def add_myself_to_tree_for_root
    
  end
end
