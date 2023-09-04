require "../crystal/repl"

module ICrystal
  class CrystalInterpreterBackend
    def initialize(*, prelude = nil)
      @repl = Crystal::Repl.new
      @repl.prelude = prelude if prelude
      @repl.prepare
    end

    def eval(code, store_history)
      syntax_check_result = check_syntax(code)
      return syntax_check_result unless syntax_check_result.status == :ok

      value = @repl.interpret_part(code)

      ExecutionResult.new(true, value.to_s, nil, nil)
    end

    def check_syntax(code)
      # TODO warnings treatment. Based on @repl.parse_code
      # TODO avoid parsing twice on eval

      warnings = @repl.program.warnings.dup
      warnings.infos = [] of String
      parser = Crystal::Parser.new code, @repl.program.string_pool, warnings: warnings
      # parser.filename = filename
      parsed_nodes = parser.parse
      # warnings.report(STDOUT)
      # @program.normalize(parsed_nodes, inside_exp: false)

      ICrystal::SyntaxCheckResult.new(:ok)
    rescue err : Crystal::SyntaxException
      case err.message.to_s
      when .includes?("EOF")
        ICrystal::SyntaxCheckResult.new(:unexpected_eof)
      when .includes?("unterminated char literal")
        # catches error for 'aa' and returns compiler error
        ICrystal::SyntaxCheckResult.new(:ok)
      when .includes?("unterminated")
        # catches unterminated hashes and arrays
        ICrystal::SyntaxCheckResult.new(:unterminated_literal)
      else
        ICrystal::SyntaxCheckResult.new(:error, err.message.to_s)
      end.tap { |result| result.err = err }
    end
  end
end
