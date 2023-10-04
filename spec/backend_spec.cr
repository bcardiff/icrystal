require "./spec_helper"

def assert_eval(backend, code, value, output = nil, error_output = nil)
  result = backend.eval(code, false)
  result.should eq(ICrystal::ExecutionResult.new(true, value, nil, output, error_output))
end

class MockBackendCallbacks
  include ICrystal::BackendCallbacks

  getter last_publish_msg_type : String?
  getter last_publish_content : ICrystal::Dict?

  def publish(msg_type : String, content : ICrystal::Dict) : Nil
    @last_publish_msg_type = msg_type
    @last_publish_content = content
  end
end

describe ICrystal do
  describe "backend" do
    it "evals" do
      callbacks = MockBackendCallbacks.new
      backend = ICrystal::CrystalInterpreterBackend.new(callbacks)
      assert_eval(backend, "1 + 2", "3")

      # def has not value output
      assert_eval(backend, "def foo; 1; end", nil)

      # Yet nil values of types like Int32 | Nil are printed
      assert_eval(backend, "nil && 1", "nil")
      # But we have this edge case unfortunately
      assert_eval(backend, "nil", nil)

      # ICrystal::None are ignored based on the runtime type
      assert_eval(backend, "ICrystal.none", nil)
      assert_eval(backend, "ICrystal.none || 1", nil)

      # Puts does not generate values
      assert_eval(backend, "puts \"Hello, World\"", nil, "Hello, World\n")
      assert_eval(backend, "puts \"1 + 2 = #{1 + 2}\"", nil, "1 + 2 = 3\n")
      assert_eval(backend, "STDERR.puts \"Oops!\"", nil, nil, "Oops!\n")
      assert_eval(backend, "STDERR.puts \"Oops * 2!\"", nil, nil, "Oops * 2!\n")

      # Backend callbacks works
      assert_eval(backend, "ICrystal.session.publish(\"foo\", {\"key\" => 1i64}); ICrystal.none", nil)
      callbacks.last_publish_msg_type.should eq "foo"
      callbacks.last_publish_content.should eq({"key" => 1i64})

      assert_eval(backend, "ICrystal.session.publish(\"bar\", {\"key\" => 2i64}); ICrystal.none", nil)
      callbacks.last_publish_msg_type.should eq "bar"
      callbacks.last_publish_content.should eq({"key" => 2i64})
    end

    it "returns syntax errors" do
      backend = ICrystal::CrystalInterpreterBackend.new(MockBackendCallbacks.new)
      result = backend.eval("a = [1", false)
      result.should be_a(ICrystal::SyntaxCheckResult)

      result = result.as(ICrystal::SyntaxCheckResult)
      result.status.should eq :unexpected_eof
    end

    it "returns compiler errors" do
      backend = ICrystal::CrystalInterpreterBackend.new(MockBackendCallbacks.new)
      result = backend.eval("1.foo", false)
      result.should eq(ICrystal::ExecutionResult.new(false, nil, nil, nil, "undefined method 'foo' for Int32"))

      assert_eval(backend, "def bar(x)\n  x.foo\nend", nil)
      result = backend.eval("bar(1)", false)
      result.should eq(ICrystal::ExecutionResult.new(false, nil, nil, nil, "instantiating 'bar(Int32)'"))
    end
  end
end
