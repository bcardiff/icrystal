# based on `require "compiler/requires"` but without some files to avoid pulling vendored deps
# that are not needed to use the interpreter

require "compiler/crystal/annotatable"
require "compiler/crystal/program"

# instead of `require "compiler/crystal/*"` we expand
#
# begin require "compiler/crystal/*"
# require "compiler/crystal/annotatable" # already included
# require "compiler/crystal/command" # skip markd shard
require "compiler/crystal/compiler"
require "compiler/crystal/config"
require "compiler/crystal/crystal_path"
require "compiler/crystal/error"
require "compiler/crystal/exception"
require "compiler/crystal/formatter"
require "compiler/crystal/loader"
require "compiler/crystal/macros"
# require "compiler/crystal/program" # already included
require "compiler/crystal/progress_tracker"
require "compiler/crystal/semantic"
require "compiler/crystal/syntax"
require "compiler/crystal/types"
require "compiler/crystal/util"
require "compiler/crystal/warnings"
# end require "compiler/crystal/*"

require "compiler/crystal/semantic/*"
require "compiler/crystal/macros/*"
require "compiler/crystal/codegen/*"

# instead of `require "compiler/crystal/interpreter/*"` we expand
# all the files to skip pry_reader, repl, and repl_reader
#
# begin require "compiler/crystal/interpreter/*"
require "compiler/crystal/interpreter/c"
require "compiler/crystal/interpreter/cast"
require "compiler/crystal/interpreter/class_vars"
require "compiler/crystal/interpreter/closure"
require "compiler/crystal/interpreter/closure_context"
require "compiler/crystal/interpreter/compiled_block"
require "compiler/crystal/interpreter/compiled_def"
require "compiler/crystal/interpreter/compiled_instructions"
require "compiler/crystal/interpreter/compiler"
require "compiler/crystal/interpreter/constants"
require "compiler/crystal/interpreter/context"
require "compiler/crystal/interpreter/debug"
require "compiler/crystal/interpreter/disassembler"
require "compiler/crystal/interpreter/escaping_exception"
require "compiler/crystal/interpreter/ffi_closure_context"
require "compiler/crystal/interpreter/instruction"
require "compiler/crystal/interpreter/instructions"
require "compiler/crystal/interpreter/interpreter"
require "compiler/crystal/interpreter/lib_function"
require "compiler/crystal/interpreter/local_vars"
require "compiler/crystal/interpreter/local_vars_gatherer"
require "compiler/crystal/interpreter/multidispatch"
require "compiler/crystal/interpreter/op_code"
require "compiler/crystal/interpreter/primitives"

# require "compiler/crystal/interpreter/pry_reader" # skip reply shard
# Stub Crystal::PryReader since it's needed in interpreter `@pry_reader : PryReader`
class Crystal::PryReader
  property? color = true
  property prompt_info = ""

  def read_next : String?
    nil.as(String?)
  end
end

require "compiler/crystal/interpreter/repl"
# require "compiler/crystal/interpreter/repl_reader" # skip reply shard

require "compiler/crystal/interpreter/to_bool"
require "compiler/crystal/interpreter/value"

# end require "compiler/crystal/interpreter/*"

class Crystal::Repl
  def prepare
    load_prelude
  end

  def interpret_part(expression)
    parser = new_parser(expression)
    # TODO change warnigns output
    parser.warnings.report(STDOUT)

    node = parser.parse
    # TODO handle errors
    # next unless node

    interpret(node)
  end
end

struct Crystal::Repl::Value
  def runtime_type : Crystal::Type
    if type.is_a?(Crystal::UnionType)
      type_id = @pointer.as(Int32*).value
      context.type_from_id(type_id)
    else
      type
    end
  end
end
