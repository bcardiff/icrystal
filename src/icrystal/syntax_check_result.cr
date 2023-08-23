class ICrystal::SyntaxCheckResult
  getter :status, :error_message
  property err : Crystal::SyntaxException?

  def initialize(@status : Symbol, @error_message : String = "")
  end
end
