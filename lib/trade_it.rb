require "trade_it/version"

require 'multi_json'
require 'yajl/json_gem'
require 'virtus'
require 'httparty'

module TradeIt
  autoload :Base, 'trade_it/base'
  autoload :User, 'trade_it/user'
  autoload :Errors, 'trade_it/errors'

  class << self
    attr_writer :logger

    attr_reader :brokers

    # Tradeit brokers as symbols
    def brokers
      return {
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

    def api_uri
      if ENV['TRADEIT_BASE_URI'] && ENV['TRADEIT_BASE_URI'] != ''
        return ENV['TRADEIT_BASE_URI']
      else
         raise TradeIt::Errors::ConfigException.new(
          type: :error,
          code: 500,
          description: "TRADEIT_BASE_URI missing",
          messages: ["TRADEIT_BASE_URI environment variable has not been set"]
        )
      end
    end

    def api_key
      if ENV['TRADEIT_API_KEY'] && ENV['TRADEIT_API_KEY'] != ''
        return ENV['TRADEIT_API_KEY']
      else
        raise TradeIt::Errors::ConfigException.new(
          type: :error,
          code: 500,
          description: "TRADEIT_API_KEY missing",
          messages: ["TRADEIT_API_KEY environment variable has not been set"]
        )
      end
    end


    def logger
      @logger ||= Logger.new($stdout).tap do |log|
        log.progname = self.name
      end
    end


  end
end
