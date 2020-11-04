require "./cryox/*"

# TODO: Write documentation for `Cryox`
module Cryox
  extend self

  VERSION = "0.1.0"
  ERROR   = 64

  def run
    if ARGV.size.zero?
      Cryox::Lox.run_repl
    elsif ARGV.size == 1
      Cryox::Lox.run_file ARGV.first
    else
      puts "Usage: cryox [script]"
      exit ERROR
    end
  end
end
