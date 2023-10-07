class ICrystal::ExecutionResult
  getter :success, :value, :value_mime_type, :output, :error_output

  def initialize(@success : Bool, @value : String?, @value_mime_type : String?, @output : String?, @error_output : String?)
  end

  def success?
    @success
  end

  def_equals_and_hash success, value, value_mime_type, output, error_output
end
