require "./spec_helper"
require "../src/std/icrystal/shards"

describe ICrystal::Shards do
  it "generates" do
    ICrystal.shards do
      github "lorem", "bcardiff/crystal-lorem"
    end
  end
end
