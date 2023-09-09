require "json"

class StartResult
  include JSON::Serializable

  property status : String

  def initialize(@status : String)
  end

  def_equals_and_hash status
end

abstract class EvalResponse
  include JSON::Serializable

  use_json_discriminator "type", {success: EvalSuccess, syntax_error: EvalSyntaxError, error: EvalError}
end

class EvalSuccess < EvalResponse
  property value : String
  property runtime_type : String
  property static_type : String

  def initialize(@value : String, @runtime_type : String, @static_type : String)
  end

  protected def on_to_json(json : ::JSON::Builder)
    json.field "type", "success"
  end

  def_equals_and_hash value, runtime_type, static_type
end

class EvalSyntaxError < EvalResponse
  property message : String
  property backtrace : Array(String)

  def initialize(@message : String, @backtrace : Array(String))
  end

  protected def on_to_json(json : ::JSON::Builder)
    json.field "type", "syntax_error"
  end

  def_equals_and_hash message, backtrace
end

class EvalError < EvalResponse
  property message : String
  property backtrace : Array(String)

  def initialize(@message : String, @backtrace : Array(String))
  end

  protected def on_to_json(json : ::JSON::Builder)
    json.field "type", "error"
  end

  def_equals_and_hash message, backtrace
end

abstract class CheckSyntaxResponse
  include JSON::Serializable

  use_json_discriminator "type", {success: CheckSyntaxSuccess, error: CheckSyntaxError}
end

class CheckSyntaxSuccess < CheckSyntaxResponse
  protected def on_to_json(json : ::JSON::Builder)
    json.field "type", "success"
  end

  def initialize
  end
end

class CheckSyntaxError < CheckSyntaxResponse
  property message : String
  property backtrace : Array(String)

  protected def on_to_json(json : ::JSON::Builder)
    json.field "type", "error"
  end

  def initialize(@message : String, @backtrace : Array(String))
  end

  def_equals_and_hash message, backtrace
end
