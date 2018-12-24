defmodule InfluxQL.Quote do
  @moduledoc """
  InfluxQL element quoting module.
  """

  alias InfluxQL.Sanitize

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

   ## Invalid identifier types

      iex> identifier(%{key: :value})
      ** (ArgumentError) invalid InfluxQL identifier: %{key: :value}

      iex> identifier({:key, :value})
      ** (ArgumentError) invalid InfluxQL identifier: {:key, :value}

      iex> identifier(<<1::4>>)
      ** (ArgumentError) invalid InfluxQL identifier: <<1::size(4)>>
  """
  @spec identifier(term) :: String.t()
  def identifier(identifier)
      when is_map(identifier) or is_tuple(identifier) or is_pid(identifier) or is_port(identifier) or
             is_reference(identifier) or is_function(identifier) or
             (is_bitstring(identifier) and not is_binary(identifier)) do
    raise ArgumentError, "invalid InfluxQL identifier: #{inspect(identifier)}"
  end

  for char <- ?0..?9 do
    def identifier(<<unquote(char), _::binary>> = identifier), do: "\"#{identifier}\""
  end

  def identifier(identifier) when is_binary(identifier) do
    case Regex.match?(~r/([^a-zA-Z0-9_])/, identifier) do
      false -> identifier
      true -> "\"#{identifier}\""
    end
  end

  def identifier(identifier), do: identifier |> Kernel.to_string() |> identifier()

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
      "'wasn\\\\'t nice'"
  """
  @spec value(term) :: String.t()
  def value(nil), do: "''"
  def value(value) when is_boolean(value), do: Kernel.to_string(value)

  def value(value) when is_atom(value),
    do: "'#{value |> Atom.to_string() |> Sanitize.escape_value()}'"

  def value(value) when is_binary(value), do: "'#{Sanitize.escape_value(value)}'"

  def value(value) when is_list(value),
    do: "'#{value |> List.to_string() |> Sanitize.escape_value()}'"

  def value(value) when is_number(value), do: Kernel.to_string(value)

  def value(value), do: raise(ArgumentError, "invalid InfluxQL value: #{inspect(value)}")
end
