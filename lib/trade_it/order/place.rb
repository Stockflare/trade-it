module TradeIt
  module Order
    class Place < TradeIt::Base
      values do
        attribute :token, String
        attribute :price, Float
      end

      def call
        uri =  URI.join(TradeIt.api_uri, 'v1/order/placeStockOrEtfOrder').to_s

        body = {
          token: token,
          apiKey: TradeIt.api_key
        }

        result = HTTParty.post(uri.to_s, body: body, format: :json)
        if result['status'] == 'SUCCESS'
          details = result['orderInfo']
          # binding.pry
          payload = {
            type: 'success',
            ticker: details['symbol'].downcase,
            order_action: TradeIt.place_order_actions.key(details['action']),
            quantity: details['quantity'].to_i,
            expiration: TradeIt.order_expirations.key(details['universalOrderInfo']['expiration']),
            price_label: details['price']['type'],
            message: result['confirmationMessage'],
            last_price: details['price']['last'].to_f,
            bid_price: details['price']['bid'].to_f,
            ask_price: details['price']['ask'].to_f,
            price_timestamp: parse_time(details['price']['timestamp']),
            timestamp: parse_time(result['timestamp']),
            order_number: result['orderNumber'],
            token: result['token'],
            price: price
          }

          self.response = TradeIt::Base::Response.new(
            raw: result,
            payload: payload,
            messages: [result['shortMessage']],
            status: 200
          )
        else
          #
          # Order failed
          #
          raise Trading::Errors::OrderException.new(
            type: :error,
            code: result['code'],
            description: result['shortMessage'],
            messages: result['longMessages']
          )
        end
        TradeIt.logger.info response.to_h
        self
      end

      def parse_time(time_string)
        Time.parse(time_string).utc.to_i
      rescue
        Time.now.utc.to_i
      end
    end
  end
end
