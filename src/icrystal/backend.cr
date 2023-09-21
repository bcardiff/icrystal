require "http/client"
require "crystal-repl-server/client"

include Crystal::Repl::Server::API

module ICrystal
  class CrystalInterpreterBackend
    @client : Crystal::Repl::Server::Client

    def initialize(*, prelude = nil)
      @socket_path = File.tempname("crystal", ".sock")

      exec_dir = File.dirname(Process.executable_path || raise "Unable to find executable path")
      crystal_repl_server_bin = Path[exec_dir, "crystal-repl-server"].to_s

      @client = Crystal::Repl::Server::Client.start_server_and_connect(server: crystal_repl_server_bin, socket: @socket_path)

      # TODO assert status ok
      @client.start
    end

    def close
      @client.close
    end

    def check_syntax(code) : SyntaxCheckResult
      response = @client.check_syntax(code)
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
      response = @client.eval(code)
      case response
      when EvalSuccess
        ExecutionResult.new(true, response.value, @client.read_stdout, @client.read_stderr)
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
  end
end
