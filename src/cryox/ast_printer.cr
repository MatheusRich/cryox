require "./expr"
require "./token"
require "./token_type"

module Cryox
  class AstPrinter
    include Expr::Visitor

    def print(expr : Expr) : String
      expr.accept(self)
    end

    def visit_binary_expr(expr : Expr::Binary)
      parenthesize(expr.operator.lexeme, expr.left, expr.right)
    end

    def visit_grouping_expr(expr : Expr::Grouping)
      parenthesize("group", expr.expression)
    end

    def visit_literal_expr(expr : Expr::Literal)
      expr.value.to_s
    end

    def visit_unary_expr(expr : Expr::Unary)
      parenthesize(expr.operator.lexeme, expr.right)
    end

    def visit_variable_expr(expr : Expr::Variable)
      parenthesize("var #{expr.name}")
    end

    def visit_assign_expr(expr : Expr::Assign)
      parenthesize("#{expr.name} = #{expr.value}")
    end

    def visit_logical_expr(expr : Expr::Logical)
      parenthesize("#{expr.left} #{expr.operator.lexeme} = #{expr.left}")
    end

    private def parenthesize(name : String, *exprs) : String
      str = "(#{name}"

      exprs.each do |expr|
        str += " "
        str += expr.accept(self)
      end
      str += ")"

      str
    end
  end
end
