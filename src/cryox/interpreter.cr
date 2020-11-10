require "./lox"
require "./token"
require "./expr"
require "./stmt"
require "./lox_obj"
require "./runtime_error"
require "./environment"

module Cryox
  class Interpreter
    include Expr::Visitor
    include Stmt::Visitor

    getter! environment : Environment

    def initialize
      @environment = Environment.new
    end

    def interpret(statements : Array(Stmt)) : Nil
      statements.each { |stmt| execute(stmt) }
    rescue e : RuntimeError
      Lox.runtime_error(e)
    end

    def visit_literal_expr(expr : Expr::Literal) : LoxObj
      expr.value
    end

    def visit_logical_expr(expr : Expr::Logical) : LoxObj
      left = evaluate(expr.left)

      case expr.operator.type
      when .or?
        return left if truthy?(left)
      else # .and?
        return left if !truthy?(left)
      end

      evaluate(expr.right)
    end

    def visit_grouping_expr(expr : Expr::Grouping) : LoxObj
      evaluate(expr.expression)
    end

    def visit_unary_expr(expr : Expr::Unary) : LoxObj
      right : LoxObj = evaluate(expr.right)

      case expr.operator.type
      when .minus?
        check_number_operand(expr.operator, right)
        return -right.as(Float64)
      when .bang?
        return !truthy?(right)
      end

      # Unreachable
      nil
    end

    def visit_variable_expr(expr : Expr::Variable) : LoxObj
      environment.get(expr.name)
    end

    def visit_binary_expr(expr : Expr::Binary) : LoxObj
      left : LoxObj = evaluate(expr.left)
      right : LoxObj = evaluate(expr.right)

      case expr.operator.type
      when .greater?
        check_number_operands(expr.operator, left, right)
        return left.as(Float64) > right.as(Float64)
      when .greater_equal?
        check_number_operands(expr.operator, left, right)

        return left.as(Float64) >= right.as(Float64)
      when .less?
        check_number_operands(expr.operator, left, right)

        return left.as(Float64) < right.as(Float64)
      when .less_equal?
        check_number_operands(expr.operator, left, right)

        return left.as(Float64) <= right.as(Float64)
      when .bang_equal?
        return !equal?(left, right)
      when .equal_equal?
        return equal?(left, right)
      when .minus?
        check_number_operands(expr.operator, left, right)

        return left.as(Float64) - right.as(Float64)
      when .plus?
        if left.is_a? Float64 && right.is_a? Float64
          return left.as(Float64) + right.as(Float64)
        end

        if left.is_a? String && right.is_a? String
          return left.to_s + right.to_s
        end

        raise RuntimeError.new(expr.operator, "Operands must be two numbers or two strings.")
      when .slash?
        check_number_operands(expr.operator, left, right)
        check_zero_division(expr.operator, right)

        return left.as(Float64) / right.as(Float64)
      when .star?
        check_number_operands(expr.operator, left, right)

        return left.as(Float64) * right.as(Float64)
      end

      # Unreachable
      nil
    end

    def visit_assign_expr(expr : Expr::Assign) : LoxObj
      value = evaluate(expr.value)
      environment.assign(expr.name, value)

      value
    end

    def visit_expression_stmt(stmt : Stmt::Expression) : Nil
      evaluate(stmt.expression)
    end

    def visit_if_stmt(stmt : Stmt::If) : Nil
      if truthy?(evaluate(stmt.condition))
        execute(stmt.then_branch)
      elsif stmt.else_branch != nil
        execute(stmt.else_branch.not_nil!)
      end
    end

    def visit_print_stmt(stmt : Stmt::Print) : Nil
      object = evaluate(stmt.expression)

      puts(stringify object)
    end

    def visit_var_stmt(stmt : Stmt::Var) : Nil
      value : LoxObj = nil
      value = evaluate(stmt.initializer) unless stmt.initializer.nil?
      environment.define(stmt.name.lexeme, value)
    end

    def visit_while_stmt(stmt : Stmt::While) : Nil
      while truthy?(evaluate(stmt.condition))
        execute(stmt.body)
      end
    end

    def visit_block_stmt(stmt : Stmt::Block) : Nil
      execute_block(stmt.statements, Environment.new(environment))
    end

    private def evaluate(expr : Expr) : LoxObj
      expr.accept(self)
    end

    private def execute(stmt : Stmt) : Nil
      stmt.accept(self)
    end

    private def execute_block(statements : Array(Stmt), new_enviroment : Environment) : Nil
      previous = @environment
      @environment = new_enviroment

      statements.each { |s| execute(s) }
    ensure
      @environment = previous
    end

    private def truthy?(object : LoxObj) : Bool
      return false if object.nil?
      return object if object.is_a? Bool

      true
    end

    private def equal?(a : LoxObj, b : LoxObj) : Bool
      return true if a.nil? && b.nil?
      return false if a.nil?

      a == b
    end

    private def stringify(object : LoxObj) : String
      return "nil" if object.nil?

      if object.is_a? Float64
        text = object.to_s
        text = text.gsub(".0", "") if text.ends_with? ".0"

        return text
      end

      object.to_s
    end

    private def check_number_operand(operator : Token, operand : LoxObj)
      return if operand.is_a? Float64

      raise RuntimeError.new(operator, "Operand must be a number.")
    end

    private def check_number_operands(operator : Token, left : LoxObj, right : LoxObj)
      return if left.is_a? Float64 && right.is_a? Float64

      raise RuntimeError.new(operator, "Operands must be numbers.")
    end

    private def check_zero_division(operator : Token, number)
      raise RuntimeError.new(operator, "Divided by zero.") if number == 0
    end
  end
end

Cryox::Interpreter.new
