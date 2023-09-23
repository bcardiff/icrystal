class ICrystal::ExecutionResult
  getter :success, :value, :output, :error_output

  def initialize(@success : Bool, @value : String?, @output : String?, @error_output : String?)
  end

  def success?
    @success
  end

  def_equals_and_hash success, value, output, error_output
end
