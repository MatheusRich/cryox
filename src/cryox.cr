require "./cryox/*"

# TODO: Write documentation for `Cryox`
module Cryox
  VERSION = "0.1.0"

  # TODO: Put your code here
end

puts Cryox::Token.new(Cryox::TokenType::NUMBER, "10.5", 10.5, 1).to_s
pp Cryox::Token.new(Cryox::TokenType::IDENTIFIER, "index", "index", 1)