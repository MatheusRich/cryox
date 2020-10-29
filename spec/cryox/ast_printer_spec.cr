require "../spec_helper"

describe Cryox::AstPrinter do
  describe "#print" do
    printer = Cryox::AstPrinter.new
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

    it "prints the correct AST" do
      printer.print(expression).should eq "(* (- 123.0) (group 45.67))"
    end
  end
end
