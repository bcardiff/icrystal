require "http/server"
require "./api"
require "../crystal/repl"

record SyntaxError, message : String, backtrace : Array(String)

def check_syntax(repl, code) : SyntaxError?
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
rescue e : Crystal::SyntaxException
  SyntaxError.new(message: e.message.to_s, backtrace: e.to_s.lines)
end

def eval(repl, code)
  syntax_error_result = check_syntax(repl, code)
  if syntax_error_result
    return EvalSyntaxError.new(syntax_error_result.message, syntax_error_result.backtrace)
  end

  begin
    value = repl.interpret_part(code)

    EvalSuccess.new(value.to_s, value.runtime_type.to_s, value.type.to_s)
  rescue ex
    EvalError.new(ex.message.to_s, ex.to_s.lines)
  end
end

repl = Crystal::Repl.new

server = HTTP::Server.new do |context|
  case {context.request.method, context.request.resource}
  when {"POST", "/v1/start"}
    repl = Crystal::Repl.new

    # TODO parse which prelude shuold be used
    # repl.prelude = prelude if prelude
    repl.prepare

    context.response.content_type = "text/json"
    result = StartResult.new(status: "ok")
    result.to_json(context.response)
  when {"POST", "/v1/check_syntax"}
    code = context.request.body.try(&.gets_to_end) || ""
    context.response.content_type = "text/json"
    check_syntax_result = check_syntax(repl, code)
    result =
      if check_syntax_result.nil?
        CheckSyntaxSuccess.new
      else
        CheckSyntaxError.new(check_syntax_result.message, check_syntax_result.backtrace)
      end

    result.to_json(context.response)
  when {"POST", "/v1/eval"}
    code = context.request.body.try(&.gets_to_end) || ""
    context.response.content_type = "text/json"
    eval(repl, code).to_json(context.response)
  end
end

socket = Socket::UNIXAddress.new(ARGV[0])
server.bind_unix socket
server.listen
