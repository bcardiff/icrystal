require "http/server"
require "json"
require "../crystal/repl"

abstract class EvalResponse
  include JSON::Serializable

  use_json_discriminator "type", {success: EvalSuccess, syntax_error: EvalSyntaxError, error: EvalError}
end

class EvalSuccess < EvalResponse
  property value : String

  def initialize(@value : String)
  end

  protected def on_to_json(json : ::JSON::Builder)
    json.field "type", "success"
  end
end

class EvalSyntaxError < EvalResponse
  property message : String

  def initialize(@message : String)
  end

  protected def on_to_json(json : ::JSON::Builder)
    json.field "type", "syntax_error"
  end
end

class EvalError < EvalResponse
  property message : String

  def initialize(@message : String)
  end

  protected def on_to_json(json : ::JSON::Builder)
    json.field "type", "error"
  end
end

def check_syntax(repl, code)
  # TODO warnings treatment. Based on @repl.parse_code
  # TODO avoid parsing twice on eval

  warnings = repl.program.warnings.dup
  warnings.infos = [] of String
  parser = Crystal::Parser.new code, repl.program.string_pool, warnings: warnings
  # parser.filename = filename
  parsed_nodes = parser.parse
  # warnings.report(STDOUT)
  # @program.normalize(parsed_nodes, inside_exp: false)

  nil
rescue err : Crystal::SyntaxException
  EvalSyntaxError.new(err.message.to_s)
end

def eval(repl, code)
  syntax_error_result = check_syntax(repl, code)
  return syntax_error_result if syntax_error_result

  begin
    value = repl.interpret_part(code)

    EvalSuccess.new(value.to_s)
  rescue ex
    EvalError.new(ex.message.to_s)
  end
end

repl = Crystal::Repl.new

server = HTTP::Server.new do |context|
  case {context.request.method, context.request.resource}
  when {"GET", "/v1/start"}
    repl = Crystal::Repl.new

    # TODO parse which prelude shuold be used
    # repl.prelude = prelude if prelude
    repl.prepare

    context.response.content_type = "text/json"
    context.response.print %({"status": "ok"})
  when {"POST", "/v1/eval"}
    code = context.request.body.try(&.gets_to_end) || ""
    context.response.content_type = "text/json"
    eval(repl, code).to_json(context.response)
  end
end

socket = Socket::UNIXAddress.new(ARGV[0])
server.bind_unix socket
server.listen
