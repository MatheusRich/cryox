class AstGenerator
  def self.run
    if ARGV.size != 1
      puts("Usage: generate_ast <output directory>")
      exit 1
    end
    output_dir = ARGV.first
    define_ast(output_dir, "Expr", [
      "Binary   = left : Expr, operator : Token, right : Expr",
      "Grouping = expression : Expr",
      "Literal  = value : Union(String | Float64 | Nil)",
      "Unary    = operator : Token, right : Expr",
    ])
  end

  private def self.define_ast(output_dir : String, base_name : String, types : Array(String))
    path = output_dir + "/" + base_name.downcase + ".cr"

    File.open(path, "w") do |file|
      file.puts "require \"./token\""
      file.puts
      file.puts "abstract class Cryox::#{base_name}"

      types.each_with_index do |type, index|
        class_name, fields = type.split("=").map(&.strip)
        define_type(file, base_name, class_name, fields, index == (types.size - 1))
      end

      file.puts "end"
    end
  end

  private def self.define_type(file, base_name : String, class_name : String, field_list : String, last? : Bool)
    file.puts "  class #{class_name} < #{base_name}"

    fields = field_list.split(", ")
    fields.each do |field|
      file.puts "    getter #{field}"
    end
    file.puts

    instance_variables = fields.map { |field| "@" + field.split(":").first.strip }
    file.puts "    def initialize(#{instance_variables.join(", ")}); end"
    file.puts "  end"
    file.puts unless last?
  end
end

AstGenerator.run
