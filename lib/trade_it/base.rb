#
# Base Tradeit Client object
#
require 'hashie'

module TradeIt
  class Base
    include Virtus.value_object(coerce: true)

    class MyHash < Hash
      include Hashie::Extensions::MethodAccess
      include Hashie::Extensions::MergeInitializer
      include Hashie::Extensions::IndifferentAccess
    end

    class Payload < Virtus::Attribute
      def coerce(value)
        Hashie::Mash.new(value)
      end
    end

    #
    # Base response for all Tradeit Calls
    #
    class Response
      include Virtus.value_object(coerce: true)
      values do
        attribute :raw, Hash
        attribute :status, Integer
        attribute :payload, Payload
        attribute :messages, Array[String]
      end
    end

    #
    # User Trading Account
    #
    class Account
      include Virtus.value_object(coerce: true)
      values do
        attribute :account_number, String
        attribute :name, String
        attribute :cash, Float
        attribute :power, Float
        attribute :day_return, Float
        attribute :day_return_percent, Float
        attribute :total_return, Float
        attribute :total_return_percent, Float
        attribute :value, Float
      end
    end

    #
    # A Position held of a single instrument
    #
    class Position
      include Virtus.value_object(coerce: true)
      values do
        attribute :quantity, Integer
        attribute :cost_basis, Float
        attribute :ticker, String
        attribute :instrument_class, String
        attribute :change, Float
        attribute :holding, String
      end
    end

    values do
      attribute :response, Response
    end
  end
end
