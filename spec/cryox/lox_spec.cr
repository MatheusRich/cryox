require "../spec_helper"
require "stdio"

describe Cryox::Lox do
  describe ".run_file" do
    it "manages scope" do
      expected_scope = "inner a\nouter b\nglobal c\nouter a\nouter b\nglobal c\nglobal a\nglobal b\nglobal c\n"
      output_of { Cryox::Lox.run_file("spec/fixtures/scope.lox") }.should eq expected_scope
    end
  end
end
