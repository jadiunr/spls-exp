module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user, :uuid

    def connect
      self.uuid = SecureRandom.urlsafe_base64
      self.current_user = find_verified_user
    end

    def find_verified_user
      params = request.query_parameters()

      access_token = params["access-token"]
      uid = params["uid"]
      client = params["client"]

      user = User.find_by(email: uid)
      if user && user.valid_token?(token, client_id)
        user
      else
        return nil
      end
    rescue
      return nil
    end
  end
end
