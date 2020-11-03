require "./macros/class_variable_property"
require "./scanner"
require "./parser"
require "./ast_printer"

module Cryox
  class Lox
    class_property had_error : Bool
    @@had_error = false

    def self.run_repl
      loop do
        print "> "
        self.run(gets || "")
        self.had_error = false
      end
    end

    def self.run_file(filename)
      self.run File.read(filename)
    rescue File::NotFoundError
      puts "File not found"
    ensure
      if had_error
        exit 65
      end
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

    private def self.report(line : Int, where : String, message : String)
      puts("[line #{line}] Error#{where}: #{message}")

      self.had_error = true
    end

    private def self.run(src)
      tokens = Scanner.new(src).scan_tokens
      parser = Parser.new(tokens)
      expression = parser.parse

      return if had_error
      return if expression.nil?

      puts AstPrinter.new.print(expression)
    end
  end
end
