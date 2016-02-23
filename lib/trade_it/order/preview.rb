module TradeIt
  module Order
    class Preview < TradeIt::Base
      values do
        attribute :token, String
        attribute :account_number, String
        attribute :order_action, Symbol
        attribute :quantity, Integer
        attribute :ticker, String
        attribute :price_type, Symbol
        attribute :expiration, Symbol
        attribute :limit_price, Float
        attribute :stop_price, Float
      end

      def call
        uri =  URI.join(TradeIt.api_uri, 'v1/order/previewStockOrEtfOrder').to_s

        body = {
          token: token,
          accountNumber: account_number,
          orderAction: TradeIt.order_actions[order_action],
          orderQuantity: quantity,
          orderSymbol: ticker,
          orderPriceType: TradeIt.price_types[price_type],
          orderExpiration: TradeIt.order_expirations[expiration],
          apiKey: TradeIt.api_key
        }

        body[:orderLimitPrice] = limit_price if price_type == :limit || price_type == :stop_limit
        body[:orderStopPrice] = stop_price if price_type == :stop_market || price_type == :stop_limit

        result = HTTParty.post(uri.to_s, body: body, format: :json)
        if result['status'] == 'REVIEW_ORDER'
          details = result['orderDetails']
          payload = {
            type: 'review',
            ticker: details['orderSymbol'],
            order_action: TradeIt.preview_order_actions.key(details['orderAction']),
            quantity: details['orderQuantity'].to_i,
            expiration: TradeIt.preview_order_expirations.key(details['orderExpiration']),
            price_label: details['orderPrice'],
            value_label: details['orderValueLabel'],
            message: details['orderMessage'],
            last_price: details['lastPrice'].to_f,
            bid_price: details['bidPrice'].to_f,
            ask_price: details['askPrice'].to_f,
            timestamp: Time.parse(details['timestamp']).utc.to_i,
            buying_power: details['buyingPower'].to_f,
            estimated_commission: details['estimatedOrderCommission'].to_f,
            estimated_value: details['estimatedOrderValue'].to_f,
            estimated_total: details['estimatedTotalValue'].to_f,
            warnings: result['warningsList'].compact,
            must_acknowledge: result['ackWarningsList'].compact,
            token: result['token']
          }

          self.response = TradeIt::Base::Response.new(
            raw: result,
            payload: payload,
            messages: result['shortMessage'].to_a.compact,
            status: 200
          )
        else
          #
          # Order failed
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
    end
  end
end
