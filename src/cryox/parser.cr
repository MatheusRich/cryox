require "./lox"
require "./token"
require "./token_type"
require "./expr"
require "./stmt"

module Cryox
  class Parser
    class ParserError < Exception; end

    getter tokens : Array(Token)
    getter current : Int32

    def initialize(@tokens, @current = 0); end

    def parse : Array(Stmt)
      statements = [] of Stmt

      until at_end?
        statements.push(declaration)
      end

      statements
    end

    private def declaration : Stmt
      return var_declaration if match(TokenType::VAR)

      statement
    rescue e : ParserError
      synchronize

      # FIXME: not sure about this
      Stmt::Expression.new(Expr::Literal.new(nil))
    end

    private def expression : Expr
      assignment
    end

    private def statement : Stmt
      return for_statement if match(TokenType::FOR)
      return if_statement if match(TokenType::IF)
      return print_statement if match(TokenType::PRINT)
      return while_statement if match(TokenType::WHILE)
      return Stmt::Block.new(block) if match(TokenType::LEFT_BRACE)

      expression_statement
    end

    private def for_statement : Stmt
      consume(TokenType::LEFT_PAREN, "Expect '(' after 'for'.")

      initializer : Stmt?
      if match(TokenType::SEMICOLON)
        initializer = nil
      elsif match(TokenType::VAR)
        initializer = var_declaration
      else
        initializer = expression_statement
      end

      condition = if !match(TokenType::SEMICOLON)
                    expression
                  else
                    Expr::Literal.new(true)
                  end
      consume(TokenType::SEMICOLON, "Expect ';' after loop condition.")

      increment : Expr? = nil
      increment = expression unless check(TokenType::RIGHT_PAREN)
      consume(TokenType::RIGHT_PAREN, "Expect ')' after for clauses.")

      body = statement

      if increment
        body = Stmt::Block.new([body, Stmt::Expression.new(increment)])
      end
      body = Stmt::While.new(condition, body)

      if initializer
        body = Stmt::Block.new([initializer, body])
      end

      body
    end

    private def if_statement : Stmt
      consume(TokenType::LEFT_PAREN, "Expect '(' after 'if'.")
      condition = expression()
      consume(TokenType::RIGHT_PAREN, "Expect ')' after if condition.")

      then_branch = statement
      else_branch = nil
      else_branch = statement if match(TokenType::ELSE)

      Stmt::If.new(condition, then_branch, else_branch)
    end

    private def print_statement : Stmt
      value = expression
      consume(TokenType::SEMICOLON, "Expect ';' after value.")

      Stmt::Print.new(value)
    end

    private def var_declaration : Stmt
      name = consume(TokenType::IDENTIFIER, "Expect variable name.")
      initializer : Expr = Expr::Literal.new(nil)
      initializer = expression if match(TokenType::EQUAL)
      consume(TokenType::SEMICOLON, "Expect ';' after variable declaration.")

      Stmt::Var.new(name, initializer)
    end

    private def while_statement : Stmt
      consume(TokenType::LEFT_PAREN, "Expect '(' after 'while'.")
      condition = expression
      consume(TokenType::RIGHT_PAREN, "Expect ')' after condition.")
      body = statement

      Stmt::While.new(condition, body)
    end

    private def expression_statement
      expr = expression
      consume(TokenType::SEMICOLON, "Expect ';' after expression.")

      Stmt::Expression.new(expr)
    end

    private def block : Array(Stmt)
      statements = [] of Stmt

      while !check(TokenType::RIGHT_BRACE) && !at_end?
        statements.push(declaration)
      end

      consume(TokenType::RIGHT_BRACE, "Expect '}' after block.")

      statements
    end

    private def assignment : Expr
      expr = or_expr

      if match(TokenType::EQUAL)
        equals = previous
        value = assignment

        if expr.is_a? Expr::Variable
          name = expr.name

          return Expr::Assign.new(name, value)
        end

        error(equals, "Invalid assignment target.")
      end

      expr
    end

    private def or_expr : Expr
      expr = and_expr

      while match(TokenType::OR)
        operator = previous
        right = and_expr
        expr = Expr::Logical.new(expr, operator, right)
      end

      expr
    end

    private def and_expr : Expr
      expr = equality

      while match(TokenType::OR)
        operator = previous
        right = equality
        expr = Expr::Logical.new(expr, operator, right)
      end

      expr
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
      return Expr::Variable.new(previous) if match(TokenType::IDENTIFIER)

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

        advance
      end
    end
  end
end
