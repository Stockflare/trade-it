module TradeIt
  module User
    class Refresh < TradeIt::Base

      values do
        attribute :token, String
      end

      def call
        uri =  URI.join(TradeIt.api_uri, 'v1/user/keepSessionAlive').to_s

        body = {
          token: self.token,
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
