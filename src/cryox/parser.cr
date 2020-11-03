require "./lox"
require "./token"
require "./token_type"
require "./expr"

module Cryox
  class Parser
    class ParserError < Exception; end

    getter tokens : Array(Token)
    getter current : Int32

    def initialize(@tokens, @current = 0); end

    def parse : Expr?
      expression
    rescue e : ParserError
      nil
    end

    private def expression : Expr
      equality
    end

    private def equality : Expr
      expr = comparison

      while match(TokenType::BANG_EQUAL, TokenType::EQUAL_EQUAL)
        operator = previous
        right = comparison
        expr = Expr::Binary.new(expr, operator, right)
      end

      expr
    end

    private def comparison : Expr
      expr = term

      while match(TokenType::GREATER, TokenType::GREATER_EQUAL, TokenType::LESS, TokenType::LESS_EQUAL)
        operator = previous
        right = term
        expr = Expr::Binary.new(expr, operator, right)
      end

      expr
    end

    private def term : Expr
      expr = factor

      while match(TokenType::MINUS, TokenType::PLUS)
        operator = previous
        right = factor
        expr = Expr::Binary.new(expr, operator, right)
      end

      expr
    end

    private def factor : Expr
      expr = unary

      while match(TokenType::SLASH, TokenType::STAR)
        operator = previous
        right = unary
        expr = Expr::Binary.new(expr, operator, right)
      end

      expr
    end

    private def unary : Expr
      if match(TokenType::BANG, TokenType::MINUS)
        operator = previous
        right = unary

        return Expr::Unary.new(operator, right)
      end

      primary
    end

    private def primary : Expr
      return Expr::Literal.new(false) if match(TokenType::FALSE)
      return Expr::Literal.new(true) if match(TokenType::TRUE)
      return Expr::Literal.new(nil) if match(TokenType::NIL)
      return Expr::Literal.new(previous.literal) if match(TokenType::NUMBER, TokenType::STRING)

      if match(TokenType::LEFT_PAREN)
        expr = expression
        consume(TokenType::RIGHT_PAREN, "Expected ')' after expression.")

        return Expr::Grouping.new(expr)
      end

      raise error(peek, "Expected expression.")
    end

    private def match(*types) : Bool
      types.each do |type|
        if check(type)
          advance

          return true
        end
      end

      false
    end

    private def consume(type : TokenType, message : String) : Token
      return advance if check(type)

      raise error(peek, message)
    end

    private def check(type : TokenType) : Bool
      return false if at_end?

      peek.type == type
    end

    private def advance
      @current += 1 unless at_end?

      previous
    end

    private def at_end? : Bool
      peek.type.eof?
    end

    private def peek : Token
      @tokens[@current]
    end

    private def previous : Token
      @tokens[@current - 1]
    end

    private def error(token : Token, message : String) : ParserError
      Lox.error(token, message)

      ParserError.new
    end

    private def synchronize : Nil
      advance

      until at_end?
        return if previous.type.semicolon?

        case peek.type
        when .class?, .fun?, .var?, .for?, .if?, .while?, .print?, .return?
          return
        end
      end

      advance
    end
  end
end