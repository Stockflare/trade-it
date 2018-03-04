module TradeIt
  module User
    class OauthUrl < TradeIt::Base
      values do
        attribute :broker, Symbol
      end

      def call
        uri =  URI.join(TradeIt.api_uri, 'v1/user/getOAuthLoginPopupUrlForWebApp?fidelityPilot=true').to_s
        body = {
          broker: TradeIt.brokers[broker],
          apiKey: TradeIt.api_key
        }
        result = HTTParty.post(uri.to_s, body: body, format: :json)

        if result['status'] == 'SUCCESS'
          self.response = TradeIt::Base::Response.new(raw: result,
                                                      status: 200,
                                                      payload: {
                                                        type: 'success',
                                                        url: result['oAuthURL']
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
