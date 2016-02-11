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
        self.log
      end

      def log
        TradeIt.logger.error self.to_h
      end
    end

    class LoginException < TradeItException
    end

    class ConfigException < TradeItException
    end
  end
end
