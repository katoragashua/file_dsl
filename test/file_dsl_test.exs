defmodule FileDslTest do
  use ExUnit.Case
  doctest FileDsl

  test "greets the world" do
    assert FileDsl.hello() == :world
  end
end
