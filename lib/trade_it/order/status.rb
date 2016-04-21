module TradeIt
  module Order
    class Status < TradeIt::Base
      values do
        attribute :token, String
        attribute :account_number, String
        attribute :order_number, String
      end

      def call
        uri =  URI.join(TradeIt.api_uri, 'v1/order/getAllOrderStatus').to_s
        uri =  URI.join(TradeIt.api_uri, 'v1/order/getSingleOrderStatus').to_s if self.order_number

        body = {
          token: token,
          accountNumber: account_number,
          apiKey: TradeIt.api_key
        }

        body[:orderNumber] = self.order_number if self.order_number


        result = HTTParty.post(uri.to_s, body: body, format: :json)
        if result['status'] == 'SUCCESS'
          details = result['orderStatusDetailsList']
          orders = []
          details.each do |detail|

            detail['orderLegs'].each do |leg|

              filled_value = leg['fills'].inject(0){|sum, f| sum + (f['quantity'].to_i * f['price'].to_f) }
              filled_quantity = leg['fills'].inject(0){|sum, f| sum + f['quantity'].to_i }
              filled_price = filled_quantity != 0 ? filled_value / filled_quantity : 0.0
              order = {
                ticker: leg['symbol'].downcase,
                order_action: TradeIt.order_status_actions[leg['action']],
                filled_quantity: filled_quantity,
                filled_price: filled_price,
                order_number: detail['orderNumber'],
                quantity: leg['orderedQuantity'].to_i,
                expiration: TradeIt.order_status_expirations[detail['orderExpiration']],
              }
              orders.push order
            end


          end
          payload = {
            type: 'success',
            orders: orders,
            token: result['token']
          }

          self.response = TradeIt::Base::Response.new(
            raw: result,
            payload: payload,
            messages: Array(result['shortMessage']),
            status: 200
          )
        else
          #
          # Status failed
          #
          fail TradeIt::Errors::OrderException.new(
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
        begin
          Time.parse(time_string).utc.to_i
        rescue
          Time.now.utc.to_i
        end
      end
    end
  end
end
