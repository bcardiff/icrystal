require "./spec_helper"
require "../src/ndjson"

describe JSON::NDParser do
  it "parses multiple JSON documents" do
    done = Channel(Nil).new
    reader, writer = IO.pipe

    spawn do
      parser = JSON::NDParser.new(reader)

      parser.parse.should eq(JSON.parse(%({"a": 1})))
      parser.parse.should eq(JSON.parse(%({"b": 2})))
      done.send nil
      parser.parse.should eq(JSON.parse(%({"c": 3})))
      done.send nil
    end

    writer.puts %({"a": 1}{"b": 2})
    # Pase writing to the pipe to ensure that the parser deals
    # correctly with being  at the end of the current stream
    done.receive

    writer.puts %({"c": 3})

    done.receive
  end
end
