require "json"

module ICrystal
  alias Any = String | Int64 | Bool | Nil
  alias Dict = Hash(String, Any | Array(Any) | Hash(String, Any) | Array(Hash(String, Any)))
end
