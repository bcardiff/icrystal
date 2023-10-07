require "./spec_helper"
require "../src/std/icrystal/dict"

def test_roundtrip(value : ICrystal::Dict)
  it "roundtrip of #{typeof(value)}" do
    value2 = ICrystal::Dict.from_json(value.to_json)
    value.should eq(value2)
  end
end

describe ICrystal::Dict do
  test_roundtrip({"k" => 1i64})
  test_roundtrip({"k" => "a"})
  test_roundtrip({"k" => true})
  test_roundtrip({"k" => nil})

  test_roundtrip({"k" => [1i64]})
  test_roundtrip({"k" => ["a"]})
  test_roundtrip({"k" => [true]})
  test_roundtrip({"k" => [nil]})

  test_roundtrip({"k" => {"k" => 1i64}})
  test_roundtrip({"k" => {"k" => "a"}})
  test_roundtrip({"k" => {"k" => true}})
  test_roundtrip({"k" => {"k" => nil}})

  test_roundtrip({"k" => [{"k" => 1i64}]})
  test_roundtrip({"k" => [{"k" => "a"}]})
  test_roundtrip({"k" => [{"k" => true}]})
  test_roundtrip({"k" => [{"k" => nil}]})
end
