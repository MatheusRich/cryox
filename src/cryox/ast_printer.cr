require "./expr"
require "./token"
require "./token_type"

module Cryox
  class AstPrinter
    # include Expr::Visitor(String)

    def print(expr : Expr) : String
      expr.accept(self)
    end

    def visit_binary_expr(expr : Expr::Binary) : String
      parenthesize(expr.operator.lexeme, expr.left, expr.right)
    end

    def visit_grouping_expr(expr : Expr::Grouping) : String
      parenthesize("group", expr.expression)
    end

    def visit_literal_expr(expr : Expr::Literal) : String
      expr.value.to_s
    end

    def visit_unary_expr(expr : Expr::Unary) : String
      parenthesize(expr.operator.lexeme, expr.right)
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

expression = Cryox::Expr::Binary.new(
  Cryox::Expr::Unary.new(
    Cryox::Token.new(Cryox::TokenType::MINUS, "-", nil, 1),
    Cryox::Expr::Literal.new(123.0)
  ),
  Cryox::Token.new(Cryox::TokenType::STAR, "*", nil, 1),
  Cryox::Expr::Grouping.new(
    Cryox::Expr::Literal.new(45.67)
  )
)

pp Cryox::AstPrinter.new.print(expression)
# puts(.print())