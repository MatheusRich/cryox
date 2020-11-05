require "./token"

module Cryox
  abstract class Stmt
    module Visitor
      abstract def visit_block_stmt(stmt : Block)
      abstract def visit_expression_stmt(stmt : Expression)
      abstract def visit_if_stmt(stmt : If)
      abstract def visit_print_stmt(stmt : Print)
      abstract def visit_var_stmt(stmt : Var)
    end

    class Block < Stmt
      getter statements : Array(Stmt)

      def initialize(@statements); end

      def accept(visitor : Visitor)
        visitor.visit_block_stmt(self)
      end
    end

    class Expression < Stmt
      getter expression : Expr

      def initialize(@expression); end

      def accept(visitor : Visitor)
        visitor.visit_expression_stmt(self)
      end
    end

    class If < Stmt
      getter condition : Expr
      getter then_branch : Stmt
      getter else_branch : Stmt?

      def initialize(@condition, @then_branch, @else_branch); end

      def accept(visitor : Visitor)
        visitor.visit_if_stmt(self)
      end
    end

    class Print < Stmt
      getter expression : Expr

      def initialize(@expression); end

      def accept(visitor : Visitor)
        visitor.visit_print_stmt(self)
      end
    end

    class Var < Stmt
      getter name : Token
      getter initializer : Expr

      def initialize(@name, @initializer); end

      def accept(visitor : Visitor)
        visitor.visit_var_stmt(self)
      end
    end

    abstract def accept(visitor : Visitor)
  end
end
