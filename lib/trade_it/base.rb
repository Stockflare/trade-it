#
# Base Tradeit Client object
#
module TradeIt
  class Base
    include Virtus.value_object(coerce: true)

    class Response
      include Virtus.value_object
      values do
        attribute :raw, Hash
        attribute :status, Integer
        attribute :payload, Hash
        attribute :messages, Array[String]
      end
    end

    values do
      attribute :response, Response
    end

  end
end
