require "./token"
require "./lox"

module Cryox
  class Scanner
    KEYWORDS = {
      "and":    TokenType::AND,
      "class":  TokenType::CLASS,
      "else":   TokenType::ELSE,
      "false":  TokenType::FALSE,
      "for":    TokenType::FOR,
      "fun":    TokenType::FUN,
      "if":     TokenType::IF,
      "nil":    TokenType::NIL,
      "or":     TokenType::OR,
      "print":  TokenType::PRINT,
      "return": TokenType::RETURN,
      "super":  TokenType::SUPER,
      "this":   TokenType::THIS,
      "true":   TokenType::TRUE,
      "var":    TokenType::VAR,
      "while":  TokenType::WHILE,
    }

    def initialize(@src : String)
      @tokens = [] of Token
      @start = 0
      @current = 0
      @line = 1
    end

    def scan_tokens : Array(Token)
      until at_end
        @start = @current
        scan_token
      end
      add_eof_token

      @tokens
    end

    private def at_end
      @current >= @src.size
    end

    private def scan_token
      c = advance

      case c
      when '('
        add_token(TokenType::LEFT_PAREN)
      when ')'
        add_token(TokenType::RIGHT_PAREN)
      when '{'
        add_token(TokenType::LEFT_BRACE)
      when '}'
        add_token(TokenType::RIGHT_BRACE)
      when ','
        add_token(TokenType::COMMA)
      when '.'
        add_token(TokenType::DOT)
      when '-'
        add_token(TokenType::MINUS)
      when '+'
        add_token(TokenType::PLUS)
      when ';'
        add_token(TokenType::SEMICOLON)
      when '*'
        add_token(TokenType::STAR)
      when '!'
        add_token(match('=') ? TokenType::BANG_EQUAL : TokenType::BANG)
      when '='
        add_token(match('=') ? TokenType::EQUAL_EQUAL : TokenType::EQUAL)
      when '<'
        add_token(match('=') ? TokenType::LESS_EQUAL : TokenType::LESS)
      when '>'
        add_token(match('=') ? TokenType::GREATER_EQUAL : TokenType::GREATER)
      when '/'
        if match '/'
          consume_comment
        else
          add_token(TokenType::SLASH)
        end
      when ' ', '\r', '\t'
        # ignore whitespaces
      when '\n'
        @line += 1
      when '"'
        consume_string
      else
        if digit?(c)
          consume_number
        elsif alpha?(c)
          consume_identifier
        else
          Lox.error(@line, "Unexpected character.")
        end
      end
    end

    private def consume_comment
      until peek == '\n' || at_end
        advance
      end
    end

    private def consume_string
      until peek == '"' || at_end
        @line += 1 if peek == '\n'
        advance
      end

      if at_end
        Lox.error(@line, "Unterminated string")
        return
      end

      # Consume the closing "
      advance

      # Trim the surrounding quotes.
      value = @src[(@start + 1)...(@current - 1)]
      add_token(TokenType::STRING, value)
    end

    private def consume_number
      while digit?(peek)
        advance
      end

      if peek == '.' && digit?(peek_next)
        # consume the .
        advance

        while digit?(peek)
          advance
        end
      end

      add_token(TokenType::NUMBER, @src[@start...@current].to_f)
    end

    private def consume_identifier
      while alphanumeric?(peek)
        advance
      end

      text = @src[@start...@current]
      type = KEYWORDS[text]? || TokenType::IDENTIFIER

      add_token(type)
    end

    private def digit?(c : Char)
      c >= '0' && c <= '9'
    end

    private def alpha?(c : Char)
      (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || c == '_'
    end

    private def alphanumeric?(c : Char)
      alpha?(c) || digit?(c)
    end

    private def peek : Char
      return '\0' if at_end

      @src[@current]
    end

    private def peek_next : Char
      return '\0' if (@current + 1) > @src.size

      @src[@current + 1]
    end

    private def advance : Char
      @current += 1

      @src[@current - 1]
    end

    private def match(expected : Char) : Bool
      return false if at_end
      return false if @src[@current] != expected

      @current += 1
      true
    end

    private def add_token(token_type)
      add_token(token_type, nil)
    end

    private def add_token(token_type, literal)
      text = @src[@start...@current]
      @tokens << Token.new(token_type, text, literal, @line)
    end

    private def add_eof_token
      @tokens << Token.new(TokenType::EOF, "", nil, @line)
    end
  end
end
