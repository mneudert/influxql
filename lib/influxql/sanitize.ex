defmodule InfluxQL.Sanitize do
  @moduledoc """
  InfluxQL sanitization module.
  """

  @re_pwd_create Regex.compile!(~s|(?i)with\s+password\s+(["']?[^\s"]+["']?)|)
  @re_pwd_set Regex.compile!(~s|(?i)password\s+for[^=]*=\s+(["']?[^\s"]+["']?)|)

  @doc """
  Escapes identifier binaries to prevent InfluxQL injection.

  ## Examples

      iex> escape_identifier("all_ok")
      "all_ok"

      iex> escape_identifier(~S(not"ok))
      ~S(not\\"ok)

      iex> escape_identifier(~S(ignore" WHERE 1=1; SELECT * FROM malicious_query --))
      ~S(ignore\\" WHERE 1=1; SELECT * FROM malicious_query --)
  """
  @spec escape_identifier(String.t()) :: String.t()
  def escape_identifier(identifier) when is_binary(identifier), do: String.replace(identifier, ~S("), ~S(\"))

  @doc """
  Escapes value binaries to prevent InfluxQL injection.

  ## Examples

      iex> escape_value("already sane")
      "already sane"

      iex> escape_value("wasn't nice")
      ~S(wasn\\'t nice)

      iex> escape_value("'; SELECT * FROM malicious_query WHERE 'a'='a")
      ~S(\\'; SELECT * FROM malicious_query WHERE \\'a\\'=\\'a)
  """
  @spec escape_value(String.t()) :: String.t()
  def escape_value(value) when is_binary(value), do: String.replace(value, "'", "\\'")

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
end
