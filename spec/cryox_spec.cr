require "./spec_helper"

describe Cryox do
  feature "branching" do |f|
    f.assert "it runs then branch on truthy conditions"
    f.assert "it runs else branch on falsey conditions"
    f.assert "it allows elsif"
    f.assert "it shorts circuits on truthy conditions"
    f.assert "it uses second operand if first is falsey"
  end

  feature "while-loops" do |f|
    f.assert "it runs on true conditions"
    f.assert "it runs on truthy conditions"
  end
end
