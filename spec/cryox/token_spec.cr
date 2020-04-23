require "../spec_helper"

describe Cryox::Token do
  subject = Cryox::Token.new(Cryox::TokenType::NUMBER, "10.5", 10.5, 1)

  it "initializes with correct values" do
    subject.type.should eq Cryox::TokenType::NUMBER
    subject.lexeme.should eq "10.5"
    subject.literal.should eq 10.5
    subject.line.should eq 1
  end

  describe "#to_s" do
    it "prints string representation" do
      subject.to_s.should eq "<NUMBER '10.5': 10.5>"
    end
  end
end
