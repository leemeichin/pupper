module Pupper
  class ParseJson < FaradayMiddleware::ParseJson
    define_parser do |body|
      Oj.load(body, symbol_keys: true) unless body.strip.empty?
    end
  end
end
