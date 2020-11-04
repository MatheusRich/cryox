require "./macros/class_variable_property"
require "./scanner"
require "./parser"
require "./interpreter"
require "./ast_printer"
require "./runtime_error"

module Cryox
  class Lox
    class_property had_error : Bool, had_runtime_error : Bool, interpreter : Interpreter
    @@had_error = false
    @@had_runtime_error = false
    @@interpreter = Interpreter.new

    def self.run_repl
      loop do
        print "> "
        # TODO: Print expressions
        self.run(gets || "")
        self.had_error = false
      end
    end

    def self.run_file(filename)
      self.run File.read(filename)
    rescue File::NotFoundError
      puts "File not found"
    ensure
      exit(65) if had_error
      exit(70) if had_runtime_error
    end

    def self.error(token : Token, message : String)
      if token.type.eof?
        report(token.line, " at end", message)
      else
        report(token.line, " at #{token.lexeme.inspect}", message)
      end
    end

    def self.error(line : Int, message : String)
      report(line, "", message)
    end

    def self.runtime_error(error : RuntimeError)
      puts "#{error.message}\n[line #{error.token.line}]"

      self.had_runtime_error = true
    end

    private def self.report(line : Int, where : String, message : String)
      puts("[line #{line}] Error#{where}: #{message}")

      self.had_error = true
    end

    private def self.run(src)
      tokens = Scanner.new(src).scan_tokens
      parser = Parser.new(tokens)
      statements = parser.parse

      return if had_error
      return if had_runtime_error

      interpreter.interpret(statements)
    end
  end
end
