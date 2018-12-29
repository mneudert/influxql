defmodule InfluxQL.Escape do
  @moduledoc """
  InfluxQL element escaping module.
  """

  @doc """
  Escapes identifier binaries to prevent InfluxQL injection.

  ## Examples

      iex> identifier("all_ok")
      "all_ok"

      iex> identifier(~S(not"ok))
      ~S(not\\"ok)

      iex> identifier(~S(ignore" WHERE 1=1; SELECT * FROM malicious_query --))
      ~S(ignore\\" WHERE 1=1; SELECT * FROM malicious_query --)
  """
  @spec identifier(String.t()) :: String.t()
  def identifier(identifier) when is_binary(identifier),
    do: String.replace(identifier, ~S("), ~S(\"))

  @doc """
  Escapes value binaries to prevent InfluxQL injection.

  ## Examples

      iex> value("already sane")
      "already sane"

      iex> value("wasn't nice")
      ~S(wasn\\'t nice)

      iex> value("'; SELECT * FROM malicious_query WHERE 'a'='a")
      ~S(\\'; SELECT * FROM malicious_query WHERE \\'a\\'=\\'a)
  """
  @spec value(String.t()) :: String.t()
  def value(value) when is_binary(value), do: String.replace(value, "'", "\\'")
end
