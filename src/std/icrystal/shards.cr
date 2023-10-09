module ICrystal
  record Shards, content : String do
    def inspect(io : IO)
      io << content
    end
  end

  def self.shards(content : String)
    # NOTE: This will not work due to https://github.com/crystal-lang/crystal/issues/12241
    # File.write(File.join(Dir.current, "shard.yml"), content)
    # puts %x(shards install)

    Shards.new(content)
  end
end
