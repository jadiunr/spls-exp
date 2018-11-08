require 'rails_helper'

RSpec.describe "StreamingSessions", type: :request do
  describe "GET /streaming_sessions" do
    it "works! (now write some real specs)" do
      get streaming_sessions_path
      expect(response).to have_http_status(200)
    end
  end
end
