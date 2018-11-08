defmodule InfluxQL.Sanitize do
  @moduledoc """
  InfluxQL sanitization module.
  """

  @re_pwd_create Regex.compile!(~s|(?i)with\s+password\s+(["']?[^\s"]+["']?)|)
  @re_pwd_set Regex.compile!(~s|(?i)password\s+for[^=]*=\s+(["']?[^\s"]+["']?)|)

  @doc """
  Removes passwords from raw queries.

  ## Examples

      iex> redact_passwords(~s(create user "admin" with password 'admin'))
      ~s(create user "admin" with password [REDACTED])

      iex> redact_passwords(~s(set password for "admin" = 'admin'))
      ~s(set password for "admin" = [REDACTED])

  Invalid statements should also have their passwords redacted.

      iex> redact_passwords(~s(create user "admin" with password "admin"))
      ~s(create user "admin" with password [REDACTED])

      iex> redact_passwords(~s(set password for "admin" = "admin"))
      ~s(set password for "admin" = [REDACTED])
  """
  @spec redact_passwords(String.t()) :: String.t()
  def redact_passwords(query) do
    query
    |> redact_slice(@re_pwd_create)
    |> redact_slice(@re_pwd_set)
  end

  defp redact_slice(query, re) do
    case Regex.run(re, query, return: :index) do
      [_, {start, len}] ->
        {prefix, _} = String.split_at(query, start)
        {_, suffix} = String.split_at(query, start + len)

        prefix <> "[REDACTED]" <> suffix

      _ ->
        query
    end
  end

  @doc """
  Prevents InfluxQL-injection in a parameter

  ## Examples

      iex> escape_parameter(100)
      100

      iex> escape_parameter(:some_atom)
      "'some_atom'"

      iex> escape_parameter(true)
      true

      iex> escape_parameter(nil)
      "''"

      iex> escape_parameter('a charlist')
      "'a charlist'"

      iex> escape_parameter("a string")
      "'a string'"

      iex> escape_parameter("I don't know")
      ~S('I don\\'t know')

      iex> escape_parameter("'; SELECT * FROM malicious_query WHERE 'a'='a")
      ~S('\\'; SELECT * FROM malicious_query WHERE \\'a\\'=\\'a')

      iex> escape_parameter({1, 2})
      ** (RuntimeError) Invalid InfluxQL parameter: {1, 2}

      iex> escape_parameter(%{key: :value})
      ** (RuntimeError) Invalid InfluxQL parameter: %{key: :value}

  """
  @spec escape_parameter(term()) :: term()
  def escape_parameter(nil) do
    "''"
  end

  def escape_parameter(param) when is_number(param) do
    param
  end

  def escape_parameter(param) when is_boolean(param) do
    param
  end

  def escape_parameter(param) when is_atom(param) do
    "'#{to_string(param)}'"
  end

  def escape_parameter(param)
      when is_map(param) or is_tuple(param) or is_pid(param) or is_port(param) or
             is_reference(param) or is_function(param) do
    raise "Invalid InfluxQL parameter: #{inspect(param)}"
  end

  def escape_parameter(param) when is_binary(param) do
    escaped =
      param
      |> to_charlist
      |> Enum.map(&escape_character/1)
      |> List.flatten()
      |> to_string

    "'#{escaped}'"
  end

  def escape_parameter(param) do
    param
    |> to_string
    |> escape_parameter
  end

  defp escape_character(?'), do: [?\\, ?']
  defp escape_character(other), do: other
end
