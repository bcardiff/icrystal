require "./spec_helper"

describe ICrystal do
  describe "backend" do
    it "evals" do
      backend = ICrystal::CrystalInterpreterBackend.new
      result = backend.eval("1 + 2", false)
      result.should be_a(ICrystal::ExecutionResult)

      result = result.as(ICrystal::ExecutionResult)
      result.success?.should be_true

      result.value.should eq "3"
      result.output.should eq ""
    end

    it "returns syntax errors" do
      backend = ICrystal::CrystalInterpreterBackend.new
      result = backend.eval("a = [1", false)
      result.should be_a(ICrystal::SyntaxCheckResult)

      result = result.as(ICrystal::SyntaxCheckResult)
      result.status.should eq :unexpected_eof
    end
  end
end
