module Braspag
  class IncompleteParams < Exception ; end
  class InvalidOrderId < Exception ; end
  class InvalidCustomerName < Exception ; end
  class InvalidCustomerId < Exception ; end
  class InvalidNumber < Exception ; end
  class InvalidInstructions < Exception ; end
  class InvalidExpirationDate < Exception ; end
  class InvalidStringFormat < Exception ; end
  class InvalidPost < Exception ; end
  class InvalidPaymentMethod < Exception ; end
  class InvalidAmount < Exception ; end
  class InvalidInstallments < Exception ; end
  class InvalidHasInterest < Exception ; end
  class InvalidIP < Exception; end
  class InvalidCryptKey < Exception; end
  class InvalidEncryptedKey < Exception; end
  class InvalidHolder < Exception ; end
  class InvalidExpirationDate < Exception ; end
  class InvalidSecurityCode < Exception ; end
  class InvalidType < Exception ; end
  class InvalidNumberPayments < Exception ; end
  class InvalidNumberInstallments < Exception ; end
  class InvalidJustClickKey < Exception ; end
  class UnknownError < Exception ; end

  class Connection
    class InvalidMerchantId < Exception ; end
    class InvalidEnvironment < Exception ; end
  end

  class Order
    class InvalidData < Exception; end
  end
end
