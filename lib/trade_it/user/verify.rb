module TradeIt
  module User
    class Verify < TradeIt::Base
      values do
        attribute :token, String
        attribute :answer, String
        attribute :identity, String
      end

      def call
        path = "v1/user/answerSecurityQuestion"
        if identity
          path = "v1/user/answerSecurityQuestion?srv=#{identity}"
        end
        uri =  URI.join(TradeIt.api_uri, path).to_s

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
