module TradeIt
  module User
    class Login < TradeIt::Base

      values do
        attribute :broker, Symbol
        attribute :username, String
        attribute :password, String
      end

      def call
        tokens = self.link

        uri =  URI.join(TradeIt.api_uri, 'v1/user/authenticate').to_s

        body = {
          userId: tokens[:userId],
          userToken: tokens[:userToken],
          apiKey: TradeIt.api_key
        }

        result = HTTParty.post(uri.to_s, body: body, format: :json)

        self.response = TradeIt::User.parse_result(result)

        TradeIt.logger.info self.response.to_h
        return self
      end

      def link
        uri =  URI.join(TradeIt.api_uri, 'v1/user/oAuthLink').to_s
        body = {
          id: self.username,
          password: self.password,
          broker: TradeIt.brokers[self.broker],
          apiKey: TradeIt.api_key
        }
        result = HTTParty.post(uri.to_s, body: body, format: :json)
        puts result
        if result['status'] == 'SUCCESS'
          return {
            userToken: result['userToken'],
            userId: result['userId']
          }
        else
          raise TradeIt::Errors::LoginException.new(
            type: :error,
            code: 500,
            description: result['shortMessage'],
            messages: result['longMessages']
          )
        end
      end
    end
  end
end
