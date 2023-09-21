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

      # def has not value output
      assert_eval(backend, "def foo; 1; end", nil)

      # Yet nil values of types like Int32 | Nil are printed
      assert_eval(backend, "nil && 1", "nil")
      # But we have this edge case unfortunately
      assert_eval(backend, "nil", nil)

      # Puts does not generate values
      assert_eval(backend, "puts \"Hello, World\"", nil, "Hello, World\n")
      assert_eval(backend, "puts \"1 + 2 = #{1 + 2}\"", nil, "1 + 2 = 3\n")
      assert_eval(backend, "STDERR.puts \"Oops!\"", nil, nil, "Oops!\n")
      assert_eval(backend, "STDERR.puts \"Oops * 2!\"", nil, nil, "Oops * 2!\n")
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
