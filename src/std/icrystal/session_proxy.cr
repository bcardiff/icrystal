require "./dict"

module ICrystal
  class SessionProxy
    # NOTE: ideally session proxy should use an ivar io instead of
    # the constant CRYSTAL_SESSION_FD. But the repl seems to have issues with
    # the life cycle of that ivar
    def initialize
    end

    getter execution_count : Int64 = 0

    def publish(msg_type : String, content : Dict) : Nil
      CRYSTAL_SESSION_FD.puts({method: "publish", msg_type: msg_type, content: content}.to_json)
    end

    # :nodoc:
    def execution_count=(@execution_count : Int64)
    end
  end
end
