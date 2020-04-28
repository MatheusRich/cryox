require "./token"

abstract class Cryox::Expr
  class Binary < Expr
    getter left : Expr
    getter operator : Token
    getter right : Expr

    def initialize(@left, @operator, @right); end
  end
end
