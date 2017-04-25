module TradeIt
  module User
    class OauthLink < TradeIt::Base
      values do
        attribute :o_auth_verifier, String
        attribute :broker, Symbol
      end

      def call
        uri =  URI.join(TradeIt.api_uri, 'v1/user/getOAuthAccessToken').to_s
        body = {
          o_auth_verifier: o_auth_verifier,
          broker: TradeIt.brokers[broker],
          apiKey: TradeIt.api_key
        }
        result = HTTParty.post(uri.to_s, body: body, format: :json)

        if result['status'] == 'SUCCESS'
          self.response = TradeIt::Base::Response.new(raw: result,
                                                      status: 200,
                                                      payload: {
                                                        type: 'success',
                                                        user_id: result['userId'],
                                                        user_token: result['userToken'],
                                                        activation_time: result['activationTime']
                                                      },
                                                      messages: [result['shortMessage']].compact)
        else
          raise Trading::Errors::LoginException.new(
            type: :error,
            code: result['code'],
            description: result['shortMessage'],
            messages: result['longMessages']
          )
        end
        # pp response.to_h
        TradeIt.logger.info response.to_h
        self
      end
    end
  end
end
