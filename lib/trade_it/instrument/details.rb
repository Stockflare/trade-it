module TradeIt
  module Instrument
    class Details < TradeIt::Base
      values do
        attribute :token, String
        attribute :ticker, String
      end

      def call
        uri =  URI.join(TradeIt.price_service_url).to_s
        result = HTTParty.get(uri.to_s, query: {symbols: ticker}, format: :json)
        if result.code == 200 && !result.empty? && result[ticker]

          payload = {
            type: 'success',
            broker_id: nil,
            ticker: ticker.downcase,
            last: result[ticker]['la'].to_f,
            bid: result[ticker]['b'].to_f,
            ask: result[ticker]['a'].to_f,
            max: 10000.0,
            min: 1.0,
            step: 1.0,
            fractional: false,
            timestamp: Time.now.utc.to_i,
            token: token
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
          raise Trading::Errors::OrderException.new(
            type: :error,
            code: result['code'],
            description: 'ticker not found',
            messages: 'ticker not found'
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
