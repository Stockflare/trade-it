module TradeIt
  module User
    class Verify < TradeIt::Base
      values do
        attribute :token, String
        attribute :answer, String
      end

      def call
        uri =  URI.join(TradeIt.api_uri, 'v1/user/answerSecurityQuestion').to_s

        body = {
          securityAnswer: answer,
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
