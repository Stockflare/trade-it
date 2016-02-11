module TradeIt
  module User
    class LinkAndLogin < TradeIt::Base

      values do
        attribute :broker, Symbol
        attribute :username, String
        attribute :password, String
      end

      def call
        link = TradeIt::User::Link.new(
          broker: broker,
          username: username,
          password: password
        ).call.response

        self.response = TradeIt::User::Login.new(
          user_id: link.payload[:user_id],
          user_token: link.payload[:user_token]
        ).call.response

        return self
      end
    end
  end
end
