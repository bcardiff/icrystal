require "http/client"
require "../interpreter/api"

module ICrystal
  class CrystalInterpreterBackend
    @socket_path : String
    @input : IO::Memory
    @output : IO::Memory
    @error : IO::Memory
    @server : Process
    @client : HTTP::Client

    def initialize(*, prelude = nil)
      @socket_path = File.tempname("crystal", ".sock")

      @input = IO::Memory.new
      @output = IO::Memory.new
      @error = IO::Memory.new

      exec_dir = File.dirname(Process.executable_path || raise "Unable to find executable path")
      @server = Process.new(Path[exec_dir, "interpreter"].to_s, {@socket_path}, input: @input, output: @output, error: @error)

      @client = retry do
        HTTP::Client.new(UNIXSocket.new(@socket_path))
      end

      # TODO assert status ok
      @client.post("/v1/start")
    end

    def close
      @server.close
      @client.close
      # TODO delete socket
      # @socket.delete
    end

    def check_syntax(code) : SyntaxCheckResult
      # TODO check status ok
      response = CheckSyntaxResponse.from_json(@client.post("/v1/check_syntax", body: code).body)
      case response
      when CheckSyntaxSuccess
        ICrystal::SyntaxCheckResult.new(:ok)
      when CheckSyntaxError
        to_icrystal_syntax_check_result(response.message)
      else
        raise NotImplementedError.new("Unknown response")
      end
    end

    def eval(code, store_history) : ExecutionResult | SyntaxCheckResult
      # TODO check status ok
      response = EvalResponse.from_json(@client.post("/v1/eval", body: code).body)
      case response
      when EvalSuccess
        eval_stdout = @output.rewind.gets_to_end.presence
        eval_stderr = @error.rewind.gets_to_end.presence
        @output.clear
        @error.clear
        res = ExecutionResult.new(true, response.value, eval_stdout, eval_stderr)
      when EvalSyntaxError
        to_icrystal_syntax_check_result(response.message)
      when EvalError
        ExecutionResult.new(false, nil, nil, response.message)
      else
        raise NotImplementedError.new("Unknown response")
      end
    end

    private def to_icrystal_syntax_check_result(message : String)
      case message
      when .includes?("EOF")
        ICrystal::SyntaxCheckResult.new(:unexpected_eof)
      when .includes?("unterminated char literal")
        # catches error for 'aa' and returns compiler error
        ICrystal::SyntaxCheckResult.new(:ok)
      when .includes?("unterminated")
        # catches unterminated hashes and arrays
        ICrystal::SyntaxCheckResult.new(:unterminated_literal)
      else
        ICrystal::SyntaxCheckResult.new(:error, message)
      end
    end

    private def retry
      last_ex = nil
      3.times do
        return yield
      rescue ex
        sleep 0.1
        last_ex = ex
      end
      raise last_ex.not_nil!
    end
  end
end
