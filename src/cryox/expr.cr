require "./token"

module Cryox
  abstract class Expr
    class Binary < Expr
      getter left : Expr
      getter operator : Token
      getter right : Expr

      def initialize(@left, @operator, @right); end

      def accept(visitor)
        visitor.visit_binary_expr(self)
      end
    end

    class Grouping < Expr
      getter expression : Expr

      def initialize(@expression); end

      def accept(visitor)
        visitor.visit_grouping_expr(self)
      end
    end

    class Literal < Expr
      getter value : Union(String | Float64 | Nil)

      def initialize(@value); end

      def accept(visitor)
        visitor.visit_literal_expr(self)
      end
    end

    class Unary < Expr
      getter operator : Token
      getter right : Expr

      def initialize(@operator, @right); end

      def accept(visitor)
        visitor.visit_unary_expr(self)
      end
    end

  end
end
