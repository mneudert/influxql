defmodule InfluxQL.Quote do
  @moduledoc """
  InfluxQL element quoting module.
  """

  @doc """
  Quotes an identifier for use in a query.

  ## Examples

      iex> identifier("unquoted")
      "unquoted"

      iex> identifier("_unquoted")
      "_unquoted"

      iex> identifier("100quotes")
      "\\"100quotes\\""

      iex> identifier("quotes for whitespace")
      "\\"quotes for whitespace\\""

      iex> identifier("dÃ¡shes-and.stÃ¼ff")
      "\\"dÃ¡shes-and.stÃ¼ff\\""
  """
  @spec identifier(String.t()) :: String.t()
  def identifier(identifier) when is_binary(identifier) do
    case Regex.match?(~r/(^[0-9]|[^a-zA-Z0-9_])/, identifier) do
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
      "foo"

      iex> value("stringy")
      "'stringy'"
  """
  @spec value(any) :: String.t()
  def value(value) when is_binary(value), do: "'#{value}'"
  def value(value), do: Kernel.to_string(value)
end
