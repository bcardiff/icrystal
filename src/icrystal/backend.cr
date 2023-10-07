require "http/client"
require "crystal-repl-server/client"
require "../ndjson"

include Crystal::Repl::Server::API

module ICrystal
  module BackendCallbacks
    abstract def publish(msg_type : String, content : Dict) : Nil
  end

  struct BackedCallbackCall
    include JSON::Serializable

    property method : String
    property msg_type : String
    property content : Dict
  end

  class CrystalInterpreterBackend
    @client : Crystal::Repl::Server::Client

    def initialize(@callbacks : BackendCallbacks)
      @socket_path = File.tempname("crystal", ".sock")

      exec_dir = File.dirname(Process.executable_path || raise "Unable to find executable path")
      crystal_repl_server_bin = Path[exec_dir, "crystal-repl-server"].to_s

      original_crystal_path = `#{crystal_repl_server_bin} env CRYSTAL_PATH`.chomp
      # TODO move std location to a compile time flag for bundling
      icrystal_std_lib = Path[exec_dir, "..", "src", "std"].to_s
      crystal_path = "#{original_crystal_path}:#{icrystal_std_lib}"

      @iopub_reader, @iopub_writer = IO.pipe
      @iopub_writer.close_on_exec = false

      @client = Crystal::Repl::Server::Client.start_server_and_connect(
        server: crystal_repl_server_bin,
        socket: @socket_path,
        env: {"CRYSTAL_PATH" => crystal_path}
      )

      spawn do
        parser = JSON::NDParser.new(@iopub_reader)
        loop do
          begin
            # TODO find a way to avoid this double parsing
            # doing `call = BackedCallbackCall.from_json(@iopub_reader)` does not work
            call = BackedCallbackCall.from_json(parser.parse.to_json)

            case call.method
            when "publish"
              callbacks.publish(call.msg_type, call.content)
            else
              Log.error { "Kernel error: method '#{call.method}' is not handled" }
            end
          rescue e
            Log.error { "Kernel error: #{e.message}\n#{e.backtrace.join('\n')}" }
          end
        end
      end

      # TODO assert status ok
      @client.start

      @client.eval(%(
        CRYSTAL_SESSION_FD = IO::FileDescriptor.new(#{@iopub_writer.fd}, blocking: false)
        CRYSTAL_SESSION_FD.close_on_exec = true
        CRYSTAL_SESSION_FD.sync = true
      ))

      @client.eval(%(require "icrystal"))

      @client.eval(%(ICrystal.init_session))
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
        if response.static_type == "Nil" && response.runtime_type == response.static_type
          # CHECK: is this a good idea? To avoid retuning nil on method defs or puts
          #        we hide the value
          ExecutionResult.new(true, nil, nil, @client.read_stdout, @client.read_stderr)
        elsif response.runtime_type == "ICrystal::None"
          ExecutionResult.new(true, nil, nil, @client.read_stdout, @client.read_stderr)
        elsif response.runtime_type == "ICrystal::Raw"
          raw_value = JSON.parse(response.value)
          ExecutionResult.new(true, raw_value["value"].as_s, raw_value["mime"].as_s, @client.read_stdout, @client.read_stderr)
        else
          ExecutionResult.new(true, response.value, nil, @client.read_stdout, @client.read_stderr)
        end
      when EvalSyntaxError
        to_icrystal_syntax_check_result(response.message)
      when EvalError
        # TODO: Check if there is a way to get better error traces
        #       in situations like
        #
        #    [1] def bar(x)
        #          x.foo
        #        end
        #
        #    [2] bar(1)
        #    >>> instantiating 'bar(Int32)'
        #
        #        There in the repl there is some tracing. Not as nice as in the compiler.
        #        But we don't even have that here.
        ExecutionResult.new(false, nil, nil, nil, response.message)
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
