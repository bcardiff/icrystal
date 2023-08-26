require "./spec_helper"

def assert_eval(backend, code, value, output = nil, error_output = nil)
  result = backend.eval(code, false)
  result.should eq(ICrystal::ExecutionResult.new(true, value, output, error_output))
end

describe ICrystal do
  describe "backend" do
    it "evals" do
      backend = ICrystal::CrystalInterpreterBackend.new
      assert_eval(backend, "1 + 2", "3")
    end

    it "returns syntax errors" do
      # using primitives as prelude due to https://github.com/crystal-lang/crystal/issues/11602
      backend = ICrystal::CrystalInterpreterBackend.new(prelude: "primitives")
      result = backend.eval("a = [1", false)
      result.should be_a(ICrystal::SyntaxCheckResult)

      result = result.as(ICrystal::SyntaxCheckResult)
      result.status.should eq :unexpected_eof
    end
  end
end
