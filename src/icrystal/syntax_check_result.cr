class ICrystal::SyntaxCheckResult
  getter :status, :error_message

  def initialize(@status : Symbol, @error_message : String = "")
  end
end
