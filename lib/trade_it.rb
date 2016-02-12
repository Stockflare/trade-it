require 'trade_it/version'

require 'multi_json'
require 'yajl/json_gem'
require 'virtus'
require 'httparty'

module TradeIt
  autoload :Base, 'trade_it/base'
  autoload :User, 'trade_it/user'
  autoload :Errors, 'trade_it/errors'
  autoload :Positions, 'trade_it/positions'
  autoload :Order, 'trade_it/order'

  class << self
    attr_writer :logger

    attr_reader :brokers

    # Tradeit brokers as symbols
    def brokers
      {
        td: 'TD',
        etrade: 'Etrade',
        scottrade: 'Scottrade',
        fidelity: 'Fidelity',
        schwab: 'Schwab',
        trade_station: 'TradeStation',
        robinhood: 'Robinhood',
        options_house: 'OptionsHouse',
        ib: 'IB',
        tradier: 'Tradier',
        dummy: 'Dummy'
      }
    end

    # Tradeit order actions
    def order_actions
      {
        buy: 'buy',
        sell: 'sell',
        buy_to_cover: 'buyToCover',
        sell_short: 'sellShort'
      }
    end

    def preview_order_actions
      {
        buy: 'Buy',
        sell: 'Sell',
        buy_to_cover: 'Buy to Cover',
        sell_short: 'Sell Short'
      }
    end
    def place_order_actions
      {
        buy: 'Buy',
        sell: 'Sell',
        buy_to_cover: 'BuyToCover',
        sell_short: 'SellShort'
      }
    end

    # Tradeit price types
    def price_types
      {
        market: 'market',
        limit: 'limit',
        stop_market: 'stopMarket',
        stop_limit: 'stopLimit'
      }
    end

    # Tradeit order expirations
    def order_expirations
      {
        day: 'day',
        gtc: 'gtc'
      }
    end

    def preview_order_expirations
      {
        day: 'Day',
        gtc: 'Good Till Cancelled'
      }
    end

    def api_uri
      if ENV['TRADEIT_BASE_URI'] && ENV['TRADEIT_BASE_URI'] != ''
        return ENV['TRADEIT_BASE_URI']
      else
        fail TradeIt::Errors::ConfigException.new(
          type: :error,
          code: 500,
          description: 'TRADEIT_BASE_URI missing',
          messages: ['TRADEIT_BASE_URI environment variable has not been set']
        )
      end
    end

    def api_key
      if ENV['TRADEIT_API_KEY'] && ENV['TRADEIT_API_KEY'] != ''
        return ENV['TRADEIT_API_KEY']
      else
        fail TradeIt::Errors::ConfigException.new(
          type: :error,
          code: 500,
          description: 'TRADEIT_API_KEY missing',
          messages: ['TRADEIT_API_KEY environment variable has not been set']
        )
      end
    end

    def logger
      @logger ||= Logger.new($stdout).tap do |log|
        log.progname = name
      end
    end
  end
end
