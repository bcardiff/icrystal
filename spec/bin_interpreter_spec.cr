# these specs run agains the ./bin/interpreter
require "spec"
require "http/client"
require "../src/interpreter/api"

class Client
  @socket_path : String
  @input : IO::Memory
  @output : IO::Memory
  @error : IO::Memory
  @server : Process
  @client : HTTP::Client

  def initialize
    @socket_path = File.tempname("crystal", ".sock")

    @input = IO::Memory.new
    @output = IO::Memory.new
    @error = IO::Memory.new

    exec_dir = Path[__DIR__].parent.join("bin", "interpreter").to_s
    @server = Process.new(exec_dir, {@socket_path}, input: @input, output: @output, error: @error)

    @client = retry do
      HTTP::Client.new(UNIXSocket.new(@socket_path))
    end
  end

  def close
    @server.close
    @client.close
    # TODO delete socket
    # @socket.delete
  end

  def raw_post(path, body)
    @client.post(path, body: body).body
  end

  def post(path, *, body = nil, as result_type : T.class) : T forall T
    result_type.from_json(raw_post(path, body: body))
  end

  private def retry
    last_ex = nil
    5.times do
      return yield
    rescue ex
      sleep 0.1
      last_ex = ex
    end
    raise last_ex.not_nil!
  end
end

def it_(description, file = __FILE__, line = __LINE__, end_line = __END_LINE__, &block : Client ->)
  it(description, file, line, end_line) do
    client = Client.new
    begin
      block.call(client)
    ensure
      client.close
    end
  end
end

describe "http interpreter" do
  it_ "can start an interpreter" do |c|
    c.post("/v1/start", as: StartResult)
      .should eq(StartResult.new("ok"))
  end

  it_ "can evaluate with prelude" do |c|
    c.post("/v1/start", as: StartResult)
    c.post("/v1/eval", body: "1 + 2", as: EvalResponse)
      .should eq(EvalSuccess.new("3", "Int32", "Int32"))
  end

  describe "can return static and runtime type information for" do
    it_ "MixedUnionType" do |c|
      c.post("/v1/start", as: StartResult)
      c.post("/v1/eval", body: "1 || \"a\"", as: EvalResponse)
        .should eq(EvalSuccess.new("1", "Int32", "(Int32 | String)"))
    end

    it_ "UnionType" do |c|
      c.post("/v1/start", as: StartResult)
      c.post("/v1/eval", body: "true || 1", as: EvalResponse)
        .should eq(EvalSuccess.new("true", "Bool", "(Bool | Int32)"))
    end
  end

  it_ "can check syntax errors" do |c|
    c.post("/v1/start", as: StartResult)
    c.post("/v1/check_syntax", body: "a = [1", as: CheckSyntaxResponse)
      .should eq(CheckSyntaxError.new(
        "expecting token ']', not 'EOF'",
        ["syntax error in :1",
         "Error: expecting token ']', not 'EOF'",
        ])
      )
    c.post("/v1/check_syntax", body: "a = 1\nb = foo(1]", as: CheckSyntaxResponse)
      .should eq(CheckSyntaxError.new(
        "expecting token ')', not ']'",
        ["syntax error in :2",
         "Error: expecting token ')', not ']'",
        ])
      )
  end

  it_ "evaluate has backtrace of compile errors" do |c|
    c.post("/v1/start", as: StartResult)
    # TODO: it seems the interpreter is unable to generate:
    #
    #  5 | 1.invalid_method
    #      ^-------------
    # Error: undefined method 'invalid_method' for Int32
    #
    # Which would be nicer output for the backtrace.
    c.post("/v1/eval", body: "1.invalid_method", as: EvalResponse)
      .should eq(EvalError.new(
        "undefined method 'invalid_method' for Int32",
        ["error in line 1",
         "Error: undefined method 'invalid_method' for Int32",
        ])
      )
  end
end
