defmodule InfluxQL.QuoteTest do
  use ExUnit.Case

  alias InfluxQL.Quote

  doctest Quote, import: true

  test "invalid identifier type: function" do
    assert_raise ArgumentError, fn -> Quote.identifier(fn -> nil end) end
  end

  test "invalid identifier type: pid" do
    assert_raise ArgumentError, fn -> Quote.identifier(self()) end
  end
end
