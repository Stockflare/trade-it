# User based actions fro the Tradeit API
#
#
module TradeIt
  module Order
    autoload :Preview, 'trade_it/order/preview'
    autoload :Place, 'trade_it/order/place'
    autoload :Status, 'trade_it/order/status'
    autoload :Cancel, 'trade_it/order/cancel'

    class << self
      def parse_order_details(details)
        orders = []
        details.each do |detail|
          detail['orderLegs'].each do |leg|
            filled_value = leg['fills'].inject(0) { |sum, f| sum + (f['quantity'].to_i * f['price'].to_f) }
            filled_quantity = leg['fills'].inject(0) { |sum, f| sum + f['quantity'].to_i }
            filled_price = filled_quantity != 0 ? filled_value / filled_quantity : 0.0
            order = {
              ticker: leg['symbol'].downcase,
              order_action: TradeIt.order_status_actions[leg['action']],
              filled_quantity: filled_quantity,
              filled_price: filled_price,
              order_number: detail['orderNumber'],
              quantity: leg['orderedQuantity'].to_i,
              expiration: TradeIt.order_status_expirations[detail['orderExpiration']],
              status: TradeIt.order_statuses[detail['orderStatus']]
            }
            orders.push order
          end
        end
        orders
      end
    end
  end
end
