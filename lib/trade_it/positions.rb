# User based actions fro the Tradeit API
#
#
module TradeIt
  module Positions
    autoload :Get, 'trade_it/positions/get'

    class << self
      #
      # Parse a Tradeit Login or Verify response into our format
      #
      def parse_result(result)
        if result['status'] == 'SUCCESS'
          #
          # User logged in without any security questions
          #
          positions = result['positions'].map do |p|
            TradeIt::Base::Position.new(
              quantity: p['quantity'],
              price: p['costbasis'],
              ticker: p['symbol'],
              instrument_class: p['symbolClass'].downcase,
              change: p['totalGainLossDollar'],
              holding: p['holdingType'].downcase
            ).to_h
          end
          response = TradeIt::Base::Response.new(raw: result,
                                                 status: 200,
                                                 payload: {
                                                   positions: positions,
                                                   pages: result['totalPages'],
                                                   page: result['currentPage'],
                                                   token: result['token']
                                                 },
                                                 messages: [result['shortMessage']].compact)
        else
          #
          # Login failed
          #
          fail TradeIt::Errors::PositionException.new(
            type: :error,
            code: 500,
            description: result['shortMessage'],
            messages: result['longMessages']
          )
        end
        response
      end
    end
  end
end
