require "./token"

module Cryox
  abstract class Expr
    module Visitor
      abstract def visit_assign_expr(expr : Assign)
      abstract def visit_binary_expr(expr : Binary)
      abstract def visit_grouping_expr(expr : Grouping)
      abstract def visit_literal_expr(expr : Literal)
      abstract def visit_logical_expr(expr : Logical)
      abstract def visit_unary_expr(expr : Unary)
      abstract def visit_variable_expr(expr : Variable)
    end

    class Assign < Expr
      getter name : Token
      getter value : Expr

      def initialize(@name, @value); end

      def accept(visitor : Visitor)
        visitor.visit_assign_expr(self)
      end
    end

    class Binary < Expr
      getter left : Expr
      getter operator : Token
      getter right : Expr

      def initialize(@left, @operator, @right); end

      def accept(visitor : Visitor)
        visitor.visit_binary_expr(self)
      end
    end

    class Grouping < Expr
      getter expression : Expr

      def initialize(@expression); end

      def accept(visitor : Visitor)
        visitor.visit_grouping_expr(self)
      end
    end

    class Literal < Expr
      getter value : Union(String | Float64 | Bool | Nil)

      def initialize(@value); end

      def accept(visitor : Visitor)
        visitor.visit_literal_expr(self)
      end
    end

    class Logical < Expr
      getter left : Expr
      getter operator : Token
      getter right : Expr

      def initialize(@left, @operator, @right); end

      def accept(visitor : Visitor)
        visitor.visit_logical_expr(self)
      end
    end

    class Unary < Expr
      getter operator : Token
      getter right : Expr

      def initialize(@operator, @right); end

      def accept(visitor : Visitor)
        visitor.visit_unary_expr(self)
      end
    end

    class Variable < Expr
      getter name : Token

      def initialize(@name); end

      def accept(visitor : Visitor)
        visitor.visit_variable_expr(self)
      end
    end

    abstract def accept(visitor : Visitor)
  end
end
