require "./token"

module Cryox
  class Scanner
    def initialize(@src : String)
      @tokens = [] of Token
      @start = 0
      @current = 0
      @line = 1
    end

    def scan_tokens
      @tokens
    end
  end
end
