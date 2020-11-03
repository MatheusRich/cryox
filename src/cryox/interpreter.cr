require "./lox"
require "./token"
require "./expr"
require "./runtime_error"

module Cryox
  class Interpreter
    alias LoxObj = String | Float64 | Bool | Nil

    include Expr::Visitor

    def interpret(expr : Expr) : Nil
      value : LoxObj = evaluate(expr)

      puts stringify(value)
    rescue e : RuntimeError
      Lox.runtime_error(e)
    end

    def visit_literal_expr(expr : Expr::Literal) : LoxObj
      expr.value
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
        !equal?(left, right)
      when .equal?
        equal?(left, right)
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

        return left.as(Float64) / right.as(Float64)
      when .star?
        check_number_operands(expr.operator, left, right)

        return left.as(Float64) * right.as(Float64)
      end

      # Unreachable
      nil
    end

    private def evaluate(expr : Expr)
      expr.accept(self)
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
  end
end

Cryox::Interpreter.new
