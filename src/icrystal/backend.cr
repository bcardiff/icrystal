require "../interpreter"

# require "compiler/crystal/syntax"

# require "icr/command"
# require "icr/command_stack"
# require "icr/executer"
# require "icr/execution_result"
# require "icr/syntax_check_result"

# module Icr
#   DELIMITER       = "|||YIH22hSkVQN|||"
#   CRYSTAL_COMMAND = "crystal"
# end

# class Icr::SyntaxCheckResult
#   property err : Crystal::SyntaxException?
# end

module ICrystal
  # class ICRBackend
  #   def initialize(debug = true)
  #     @command_stack = Icr::CommandStack.new
  #     @executer = Icr::Executer.new(@command_stack, debug)
  #   end

  #   def eval(code, store_history)
  #     check_result = check_syntax(code)
  #     process_result(check_result, code)
  #   end

  #   def check_syntax(code)
  #     Crystal::Parser.parse(code)
  #     Icr::SyntaxCheckResult.new(:ok)
  #   rescue err : Crystal::SyntaxException
  #     case err.message.to_s
  #     when .includes?("EOF")
  #       Icr::SyntaxCheckResult.new(:unexpected_eof)
  #     when .includes?("unterminated char literal")
  #       # catches error for 'aa' and returns compiler error
  #       Icr::SyntaxCheckResult.new(:ok)
  #     when .includes?("unterminated")
  #       # catches unterminated hashes and arrays
  #       Icr::SyntaxCheckResult.new(:unterminated_literal)
  #     else
  #       Icr::SyntaxCheckResult.new(:error, err.message.to_s)
  #     end.tap { |result| result.err = err }
  #   end

  #   private def process_result(check_result : Icr::SyntaxCheckResult, command : String)
  #     case check_result.status
  #     when :ok
  #       @command_stack.push(command)
  #       @executer.execute
  #     when :unexpected_eof, :unterminated_literal
  #       # If syntax is invalid because of unexpected EOF, or
  #       # we are still waiting for a closing bracket, keep asking for input
  #       check_result
  #     when :error
  #       # Give it the second try, validate the command in scope of entire file
  #       @command_stack.push(command)
  #       entire_file_result = check_syntax(@command_stack.to_code)
  #       case entire_file_result.status
  #       when :ok
  #         @executer.execute
  #       when :unexpected_eof
  #         @command_stack.pop
  #         process_result(entire_file_result, command)
  #       else
  #         @command_stack.pop
  #         entire_file_result
  #       end
  #     else
  #       raise("Unknown SyntaxCheckResult status: #{check_result.status}")
  #     end
  #   end
  # end

  class CrystalInterpreterBackend
    def initialize
      @program = Crystal::Program.new
      @context = Crystal::Repl::Context.new(@program)
      @main_visitor = Crystal::MainVisitor.new(@program)

      @interpreter = Crystal::Repl::Interpreter.new(@context)
    end

    def eval(code, store_history)
      ExecutionResult.new(true, "result", "output", nil)
    end

    def check_syntax(code)
      Crystal::Parser.parse(code)
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

    # private def process_result(check_result : ICrystal::SyntaxCheckResult, command : String)
    #   case check_result.status
    #   when :ok
    #     @command_stack.push(command)
    #     @executer.execute
    #   when :unexpected_eof, :unterminated_literal
    #     # If syntax is invalid because of unexpected EOF, or
    #     # we are still waiting for a closing bracket, keep asking for input
    #     check_result
    #   when :error
    #     # Give it the second try, validate the command in scope of entire file
    #     @command_stack.push(command)
    #     entire_file_result = check_syntax(@command_stack.to_code)
    #     case entire_file_result.status
    #     when :ok
    #       @executer.execute
    #     when :unexpected_eof
    #       @command_stack.pop
    #       process_result(entire_file_result, command)
    #     else
    #       @command_stack.pop
    #       entire_file_result
    #     end
    #   else
    #     raise("Unknown SyntaxCheckResult status: #{check_result.status}")
    #   end
    # end
  end
end
