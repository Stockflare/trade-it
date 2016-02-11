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
        if result['status'] == 'SUCCESS'
          #
          # User logged in without any security questions
          #
          self.response = Response.new({
            raw: result,
            status: 200,
            payload: {
              type: 'success',
              token: result["token"],
              accounts: result['accounts']
            },
            messages: [result['shortMessage']]
          })
        elsif result['status'] == 'INFORMATION_NEEDED'
          #
          # User Asked for security question
          #
          if result['challengeImage']
            data = {
              encoded: result['challengeImage']
            }
          else
            data = {
              question: result['securityQuestion'],
              answers: result['securityQuestionOptions']
            }
          end
          self.response = Response.new({
            raw: result,
            status: 200,
            payload: {
              type: 'verify',
              challenge: result['challengeImage'] ? 'image' : 'question',
              token: result["token"],
              data: data
            },
            messages: [result['shortMessage']]
          })
        else
          #
          # Login failed
          #
          raise TradeIt::Errors::LoginException.new(
            type: :error,
            code: 500,
            description: result['shortMessage'],
            messages: result['longMessages']
          )
        end
        TradeIt.logger.info self.response.to_h
        pp(response.to_h)
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
