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

  test "invalid value type: function" do
    assert_raise ArgumentError, fn -> Quote.value(fn -> nil end) end
  end

  test "invalid value type: pid" do
    assert_raise ArgumentError, fn -> Quote.value(self()) end
  end
end
