# User based actions fro the Tradeit API
#
#
module TradeIt
  module Order
    autoload :Preview, 'trade_it/order/preview'
    autoload :Place, 'trade_it/order/place'
    autoload :Status, 'trade_it/order/status'

    class << self
    end
  end
end
