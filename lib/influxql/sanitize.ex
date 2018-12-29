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
end
