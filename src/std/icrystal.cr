require "json"
require "./icrystal/session_proxy"

module ICrystal
  @@session : SessionProxy? = nil

  # A `ICrystal::Raw` value is as json. This json is deserialized by the kernel and
  # displayed as appropriate. This is possible because the the kernel knows the
  # type of the result and there is custom logic for `ICrystal::Raw`.
  record Raw, mime : String, value : String do
    def inspect(io : IO)
      JSON.build(io) do |builder|
        builder.object do
          builder.field("mime", mime)
          builder.field("value", value)
        end
      end
    end
  end

  # A `ICrystal::None` value will dismiss the default rendering of values.
  struct None
  end

  def self.html(value : String)
    Raw.new(mime: "text/html", value: value)
  end

  def self.svg(value : String)
    Raw.new(mime: "image/svg+xml", value: value)
  end

  def self.json(value)
    Raw.new(mime: "application/json", value: value.to_json)
  end

  def self.none
    None.new
  end

  def self.session : SessionProxy
    @@session.not_nil!("session not initialized")
  end

  # :nodoc:
  def self.init_session : Nil
    @@session = SessionProxy.new
  end
end
