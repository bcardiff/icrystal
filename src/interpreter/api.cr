require "json"

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

  protected def on_to_json(json : ::JSON::Builder)
    json.field "type", "error"
  end

  def initialize(@message : String)
  end
end
