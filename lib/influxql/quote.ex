defmodule InfluxQL.Quote do
  @moduledoc """
  InfluxQL element quoting module.
  """

  alias InfluxQL.Escape

  @doc """
  Quotes an identifier for use in a query.

  ## Examples

      iex> identifier(:from_atom)
      "from_atom"

      iex> identifier("unquoted")
      "unquoted"

      iex> identifier("unquoted_100")
      "unquoted_100"

      iex> identifier("_unquoted")
      "_unquoted"

      iex> identifier("100quotes")
      "\\"100quotes\\""

      iex> identifier("quotes for whitespace")
      "\\"quotes for whitespace\\""

      iex> identifier("dÃ¡shes-and.stÃ¼ff")
      "\\"dÃ¡shes-and.stÃ¼ff\\""

      iex> identifier("a.b")
      "\\"a.b\\""

      iex> identifier(42)
      "\\"42\\""

      iex> identifier(5.7)
      "\\"5.7\\""

      iex> identifier('cl')
      "cl"

      iex> identifier([])
      ""

      iex> identifier([65])
      "A"

   ## Invalid identifier types

      iex> identifier(%{key: :value})
      ** (ArgumentError) invalid InfluxQL identifier: %{key: :value}

      iex> identifier({:key, :value})
      ** (ArgumentError) invalid InfluxQL identifier: {:key, :value}

      iex> identifier(<<1::4>>)
      ** (ArgumentError) invalid InfluxQL identifier: <<1::size(4)>>

  ## InfluxQL injection prevention

      iex> identifier(~S(wasnot"nice))
      ~S("wasnot\\"nice")
  """
  @spec identifier(term) :: String.t()
  for char <- ?0..?9 do
    def identifier(<<unquote(char), _::binary>> = identifier), do: "\"#{identifier}\""
  end

  def identifier(identifier) when is_binary(identifier) do
    case Regex.match?(~r/([^a-zA-Z0-9_])/, identifier) do
      false -> identifier
      true -> ~s("#{Escape.identifier(identifier)}")
    end
  end

  def identifier(identifier)
      when is_atom(identifier) or is_number(identifier) or is_list(identifier) or
             is_boolean(identifier),
      do: identifier |> to_string() |> identifier()

  def identifier(identifier),
    do: raise(ArgumentError, "invalid InfluxQL identifier: #{inspect(identifier)}")

  @doc """
  Quotes a value for use in a query.

  ## Examples

      iex> value(100)
      "100"

      iex> value(:foo)
      "'foo'"

      iex> value(false)
      "false"

      iex> value(nil)
      "''"

      iex> value("stringy")
      "'stringy'"

      iex> value('charlisty')
      "'charlisty'"

   ## Invalid value types

      iex> value(%{key: :value})
      ** (ArgumentError) invalid InfluxQL value: %{key: :value}

      iex> value({:key, :value})
      ** (ArgumentError) invalid InfluxQL value: {:key, :value}

      iex> value(<<1::4>>)
      ** (ArgumentError) invalid InfluxQL value: <<1::size(4)>>

  ## InfluxQL injection prevention

      iex> value("wasn't nice")
      ~S('wasn\\'t nice')
  """
  @spec value(term) :: String.t()
  def value(nil), do: "''"

  def value(value) when is_boolean(value) or is_number(value), do: to_string(value)

  def value(value) when is_binary(value), do: "'#{Escape.value(value)}'"

  def value(value) when is_atom(value) or is_list(value), do: value |> to_string() |> value()

  def value(value), do: raise(ArgumentError, "invalid InfluxQL value: #{inspect(value)}")
end
