require "./token"
require "./runtime_error"
require "./lox_obj"

module Cryox
  class Environment
    getter! values : Hash(String, LoxObj)
    getter enclosing : Environment | Nil

    def initialize(enclosing = nil)
      @values = {} of String => LoxObj
      @enclosing = enclosing
    end

    def define(name : String, value : LoxObj) : Nil
      values[name] = value
    end

    def get(name : Token) : LoxObj
      return values[name.lexeme] if values.has_key?(name.lexeme)
      return enclosing.not_nil!.get(name) unless enclosing.nil?

      raise RuntimeError.new(name, "Undefined variable '#{name.lexeme}'.")
    end

    def assign(name : Token, value : LoxObj) : Nil
      return values[name.lexeme] = value if values.has_key?(name.lexeme)
      return enclosing.not_nil!.assign(name, value) unless enclosing.nil?

      raise RuntimeError.new(name, "Undefined variable '#{name.lexeme}'.")
    end
  end
end
