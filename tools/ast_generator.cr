module AstGenerator
  extend self

  def run
    if ARGV.size != 1
      puts("Usage: generate_ast <output directory>")
      puts("  tip: $ crystal run tools/ast_generator.cr -- src/cryox")
      exit 1
    end

    output_dir = ARGV.first

    define_ast(output_dir, "Expr", [
      "Binary   = left : Expr, operator : Token, right : Expr",
      "Grouping = expression : Expr",
      "Literal  = value : Union(String | Float64 | Bool | Nil)",
      "Unary    = operator : Token, right : Expr",
    ])

    define_ast(output_dir, "Stmt", [
      "Expression = expression : Expr",
      "Print      = expression : Expr",
    ])
  end

  private def define_ast(output_dir : String, base_name : String, types : Array(String))
    path = output_dir + "/" + base_name.downcase + ".cr"

    File.open(path, "w") do |file|
      file.puts "require \"./token\""
      file.puts
      file.puts "module Cryox"
      file.puts "  abstract class #{base_name}"

      define_visitor_interface(file, base_name, types)
      define_ast_types(file, base_name, types)

      file.puts
      file.puts "    abstract def accept(visitor : Visitor)"

      file.puts "  end"
      file.puts "end"
    end
  end

  private def define_visitor_interface(file, base_name, types)
    file.puts "    module Visitor"

    types.each do |type|
      type_name, _ = type.split("=").map(&.strip)
      file.puts "      abstract def visit_#{type_name.downcase}_#{base_name.downcase}(#{base_name.downcase} : #{type_name})"
    end
    file.puts "    end"
    file.puts
  end

  private def define_ast_types(file, base_name, types)
    types.each_with_index do |type, index|
      class_name, fields = type.split("=").map(&.strip)
      is_last = index == (types.size - 1)

      define_type(file, base_name, class_name, fields, is_last)
    end
  end

  private def define_type(file, base_name : String, class_name : String, field_list : String, last? : Bool)
    file.puts "    class #{class_name} < #{base_name}"

    fields = field_list.split(", ")

    define_getters(file, fields)
    define_initializer(file, fields)
    define_visitor(file, class_name, base_name)

    file.puts "    end"
    file.puts unless last?
  end

  private def define_getters(file, fields)
    fields.each do |field|
      file.puts "      getter #{field}"
    end
    file.puts
  end

  private def define_initializer(file, fields)
    instance_variables = fields.map { |field| "@" + field.split(":").first.strip }
    file.puts "      def initialize(#{instance_variables.join(", ")}); end"
  end

  private def define_visitor(file, class_name, base_name)
    file.puts
    file.puts "      def accept(visitor : Visitor)"
    file.puts "        visitor.visit_#{class_name.downcase}_#{base_name.downcase}(self)"
    file.puts "      end"
  end
end

AstGenerator.run
