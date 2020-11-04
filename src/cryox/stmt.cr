require "./token"

module Cryox
  abstract class Stmt
    module Visitor
      abstract def visit_expression_stmt(stmt : Expression)
      abstract def visit_print_stmt(stmt : Print)
    end

    class Expression < Stmt
      getter expression : Expr

      def initialize(@expression); end

      def accept(visitor : Visitor)
        visitor.visit_expression_stmt(self)
      end
    end

    class Print < Stmt
      getter expression : Expr

      def initialize(@expression); end

      def accept(visitor : Visitor)
        visitor.visit_print_stmt(self)
      end
    end

    abstract def accept(visitor : Visitor)
  end
end