require "./macros/class_variable_property"
require "./scanner"

module Cryox
  class Lox
    class_property had_error : Bool
    @@had_error = false

    def self.repl
      print "> "
      self.run(gets || "")
      self.had_error = false
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

    private def self.run(src)
      tokens = Scanner.new(src).scan_tokens
      puts tokens
    end
  end
end
