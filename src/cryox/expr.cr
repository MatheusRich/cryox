require "./token"

abstract class Cryox::Expr
  class Binary < Expr
    getter left : Expr
    getter operator : Token
    getter right : Expr

    def initialize(@left, @operator, @right); end
  end

  class Grouping < Expr
    getter expression : Expr

    def initialize(@expression); end
  end

  class Literal < Expr
    getter value : Union(String | Float64 | Nil)

    def initialize(@value); end
  end

  class Unary < Expr
    getter operator : Token
    getter right : Expr

    def initialize(@operator, @right); end
  end
end
