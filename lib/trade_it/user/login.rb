module TradeIt
  module User
    class Login < TradeIt::Base

      values do
        attribute :user_id, String
        attribute :user_token, String
      end

      def call
        uri =  URI.join(TradeIt.api_uri, 'v1/user/authenticate').to_s

        body = {
          userId: self.user_id,
          userToken: self.user_token,
          apiKey: TradeIt.api_key
        }

        result = HTTParty.post(uri.to_s, body: body, format: :json)

        self.response = TradeIt::User.parse_result(result)

        TradeIt.logger.info self.response.to_h
        return self
      end
    end
  end
end
