module TradeIt
  module User
    class Link < TradeIt::Base

      values do
        attribute :broker, Symbol
        attribute :username, String
        attribute :password, String
      end

      def call
        uri =  URI.join(TradeIt.api_uri, 'v1/user/oAuthLink').to_s
        body = {
          id: self.username,
          password: self.password,
          broker: TradeIt.brokers[self.broker],
          apiKey: TradeIt.api_key
        }
        result = HTTParty.post(uri.to_s, body: body, format: :json)

        if result['status'] == 'SUCCESS'
          self.response = TradeIt::Base::Response.new({
            raw: result,
            status: 200,
            payload: {
              type: 'success',
              user_id: result['userId'],
              user_token: result["userToken"]
            },
            messages: [result['shortMessage']].compact
          })
        else
          raise TradeIt::Errors::LoginException.new(
            type: :error,
            code: 500,
            description: result['shortMessage'],
            messages: result['longMessages']
          )
        end
        TradeIt.logger.info self.response.to_h
        return self
      end
    end
  end
end
