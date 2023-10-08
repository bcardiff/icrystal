module ICrystal
  def self.shards(content : String)
    File.write(File.join(Dir.current, "shard.yml"), content)
    # NOTE: This will not work due to https://github.com/crystal-lang/crystal/issues/12241
    puts %x(shards install)

    puts "Shards installed"
  end
end
