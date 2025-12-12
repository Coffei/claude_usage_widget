defmodule ClaudeUsageWidget.Api do
  @moduledoc """
  HTTP client for fetching usage data from the Claude API.
  Uses curl to bypass Cloudflare bot detection.
  """

  @base_url "https://claude.ai"

  def fetch_usage(session_token, organization_id) do
    url = "#{@base_url}/api/organizations/#{organization_id}/usage"

    args = [
      "-s",
      "-w",
      "\n%{http_code}",
      "-X",
      "GET",
      url,
      "-H",
      "Cookie: sessionKey=#{session_token}",
      "-H",
      "Accept: application/json",
      "-H",
      "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
      "-H",
      "Origin: #{@base_url}",
      "-H",
      "Referer: #{@base_url}/"
    ]

    case System.cmd("curl", args, stderr_to_stdout: true) do
      {output, 0} ->
        parse_curl_response(output)

      {error_output, _exit_code} ->
        {:error, {:curl_failed, error_output}}
    end
  end

  defp parse_curl_response(output) do
    lines = String.split(output, "\n")
    status_code = lines |> List.last() |> String.trim() |> String.to_integer()
    body = lines |> Enum.drop(-1) |> Enum.join("\n")

    case status_code do
      200 ->
        {:ok, Jason.decode!(body)}

      401 ->
        {:error, :unauthorized}

      403 ->
        {:error, {:forbidden, body}}

      status ->
        {:error, {:http_error, status, body}}
    end
  end
end
