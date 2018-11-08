require "rails_helper"

RSpec.describe StreamingSessionsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(:get => "/streaming_sessions").to route_to("streaming_sessions#index")
    end

    it "routes to #show" do
      expect(:get => "/streaming_sessions/1").to route_to("streaming_sessions#show", :id => "1")
    end


    it "routes to #create" do
      expect(:post => "/streaming_sessions").to route_to("streaming_sessions#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/streaming_sessions/1").to route_to("streaming_sessions#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/streaming_sessions/1").to route_to("streaming_sessions#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/streaming_sessions/1").to route_to("streaming_sessions#destroy", :id => "1")
    end
  end
end
