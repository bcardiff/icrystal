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

  def self.shards
    builder = ShardsBuilder.new
    with builder yield builder
    shards(builder.shards_yml)
  end

  # :nodoc:
  class ShardsBuilder
    def initialize
      @dependencies = [] of GitHubDependency
    end

    def shards_yml
      String.build do |str|
        str << <<-YML
          name: notebook
          version: 0.0.1
          license: MIT

          dependencies:

          YML

        @dependencies.each do |dep|
          str << "  #{dep.name}:\n"
          str << "    github: #{dep.repository}\n"
        end
      end
    end

    class GitHubDependency
      property name : String
      property repository : String

      def initialize(@name : String, @repository : String)
      end
    end

    def dep(name : String, *, github repository : String)
      @dependencies << GitHubDependency.new(name, repository)
    end
  end
end
