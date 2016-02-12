module TradeIt
  module Errors
    class TradeItException < Exception
      include Virtus.value_object

      values do
        attribute :type, Symbol
        attribute :code, Integer
        attribute :description, String
        attribute :messages, Array[String]
      end

      def initialize(*args)
        super
        log
      end

      def log
        pp(to_h)
        TradeIt.logger.error to_h
      end
    end

    class LoginException < TradeItException
    end

    class ConfigException < TradeItException
    end

    class ConfigException < TradeItException
    end

    class PositionException < TradeItException
    end

    class OrderException < TradeItException
    end
  end
end
