module TradeIt
  module User
    class Logout < TradeIt::Base
      values do
        attribute :token, String
      end

      def call
        uri =  URI.join(TradeIt.api_uri, 'v1/user/closeSession').to_s

        body = {
          token: token,
          apiKey: TradeIt.api_key
        }

        result = HTTParty.post(uri.to_s, body: body, format: :json)
        self.response = TradeIt::User.parse_result(result)

        TradeIt.logger.info response.to_h
        self
      end
    end
  end
end
