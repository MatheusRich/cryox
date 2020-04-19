require "./token_type"

module Cryox
  class Token
    getter type : TokenType
    getter lexeme : String
    getter literal : String
    getter line : Int32

    def initialize(@type, @lexeme, @literal, @line); end

    def inspect
      "<#{type} '#{lexeme}': #{literal} >"
    end

    delegate :to_s, to: :inspect
  end
end
