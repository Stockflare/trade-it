#
# Base Tradeit Client object
#
module TradeIt
  class Base
    include Virtus.value_object(coerce: true)

    #
    # Base response for all Tradeit Calls
    #
    class Response
      include Virtus.value_object(coerce: true)
      values do
        attribute :raw, Hash
        attribute :status, Integer
        attribute :payload, Hash
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
      end
    end

    #
    # A Position held of a single instrument
    #
    class Position
      include Virtus.value_object(coerce: true)
      values do
        attribute :quantity, Integer
        attribute :price, Float
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
