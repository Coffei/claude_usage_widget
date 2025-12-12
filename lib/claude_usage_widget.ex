defmodule ClaudeUsageWidget do
  @moduledoc """
  CLI application for fetching and displaying Claude AI usage statistics.
  """

  alias ClaudeUsageWidget.{Api, Config, Formatter}

  def main(args) do
    mode = parse_args(args)

    case run(mode) do
      {:ok, output} ->
        IO.puts(output)

      {:error, reason} ->
        print_error(reason, mode)
        System.halt(1)
    end
  end

  defp parse_args(args) do
    case args do
      ["--short" | _] -> :short
      ["-s" | _] -> :short
      ["--argos" | _] -> :argos
      ["-a" | _] -> :argos
      _ -> :verbose
    end
  end

  defp run(mode) do
    with {:ok, config} <- Config.read(),
         {:ok, usage_data} <- Api.fetch_usage(config.session_token, config.organization_id) do
      {:ok, Formatter.format(usage_data, mode)}
    end
  end

  defp print_error(:not_found, mode) when mode in [:short, :argos],
    do: IO.puts(:stderr, "Config not set up")

  defp print_error(:not_found, _mode) do
    IO.puts(:stderr, Config.setup_instructions())
  end

  defp print_error(:invalid_json, mode) when mode in [:short, :argos],
    do: IO.puts(:stderr, "Error: Invalid JSON in config")

  defp print_error(:invalid_json, _mode) do
    IO.puts(:stderr, "Error: Configuration file contains invalid JSON")
  end

  defp print_error({:missing_field, field}, mode) when mode in [:short, :argos],
    do: IO.puts(:stderr, "Error: Missing '#{field}' in config")

  defp print_error({:missing_field, field}, _mode) do
    IO.puts(:stderr, "Error: Missing required field '#{field}' in config file")
  end

  defp print_error({:empty_field, field}, mode) when mode in [:short, :argos],
    do: IO.puts(:stderr, "Error: Empty '#{field}' in config")

  defp print_error({:empty_field, field}, _mode) do
    IO.puts(:stderr, "Error: Field '#{field}' cannot be empty in config file")
  end

  defp print_error(:unauthorized, mode) when mode in [:short, :argos],
    do: IO.puts(:stderr, "Error: Invalid or expired session token")

  defp print_error(:unauthorized, _mode) do
    IO.puts(
      :stderr,
      "Error: Session token is invalid or expired. Please update your config file."
    )
  end

  defp print_error(:forbidden, mode) when mode in [:short, :argos],
    do: IO.puts(:stderr, "Error: Access forbidden (check org ID)")

  defp print_error(:forbidden, _mode) do
    IO.puts(:stderr, "Error: Access forbidden. Check your organization ID.")
  end

  defp print_error({:http_error, status, _body}, mode) when mode in [:short, :argos],
    do: IO.puts(:stderr, "Error: HTTP #{status}")

  defp print_error({:http_error, status, body}, _mode) do
    IO.puts(:stderr, "Error: HTTP #{status} - #{inspect(body)}")
  end

  defp print_error({:request_failed, _exception}, mode) when mode in [:short, :argos],
    do: IO.puts(:stderr, "Error: Request failed")

  defp print_error({:request_failed, exception}, _mode) do
    IO.puts(:stderr, "Error: Request failed - #{Exception.message(exception)}")
  end

  defp print_error({:file_error, _reason}, mode) when mode in [:short, :argos],
    do: IO.puts(:stderr, "Error: Can't read config file")

  defp print_error({:file_error, reason}, _mode) do
    IO.puts(:stderr, "Error: Could not read config file - #{inspect(reason)}")
  end

  defp print_error(other, _mode) do
    IO.puts(:stderr, "Error: #{inspect(other)}")
  end
end
