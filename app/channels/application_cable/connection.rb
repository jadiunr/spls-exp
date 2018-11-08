module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user, :uuid

    def connect
      self.current_user = find_verified_user
      self.uuid = SecureRandom.urlsafe_base64
    end

    def find_verified_user
      params = request.query_parameters()

      access_token = params["access-token"]
      uid = params["uid"]
      client = params["client"]

      user = User.find_by(email: uid)
      if user && user.valid_token?(access_token, client)
        user
      else
        return nil
      end
    rescue
      return nil
    end
  end
end
