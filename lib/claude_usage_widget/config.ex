defmodule ClaudeUsageWidget.Config do
  @moduledoc """
  Handles reading and validation of the configuration file.
  """

  @config_path "~/.config/claude_usage/config.json"

  def config_path do
    Path.expand(@config_path)
  end

  def read do
    path = config_path()

    case File.read(path) do
      {:ok, contents} ->
        parse(contents)

      {:error, :enoent} ->
        {:error, :not_found}

      {:error, reason} ->
        {:error, {:file_error, reason}}
    end
  end

  defp parse(contents) do
    case Jason.decode(contents) do
      {:ok, config} ->
        validate(config)

      {:error, _} ->
        {:error, :invalid_json}
    end
  end

  defp validate(config) do
    with {:ok, session_token} <- get_required(config, "session_token"),
         {:ok, organization_id} <- get_required(config, "organization_id") do
      {:ok, %{session_token: session_token, organization_id: organization_id}}
    end
  end

  defp get_required(config, key) do
    case Map.get(config, key) do
      nil -> {:error, {:missing_field, key}}
      "" -> {:error, {:empty_field, key}}
      value -> {:ok, value}
    end
  end

  def setup_instructions do
    """
    Configuration file not found at ~/.config/claude_usage/config.json

    To set up:
    1. Login to https://claude.ai
    2. Open Developer Tools (F12)
    3. Navigate to: Application → Storage → Cookies → https://claude.ai
    4. Find the sessionKey cookie
    5. Copy its value (starts with sk-ant-sid-...)
    6. Go to https://claude.ai/settings/account
    7. Copy the Organization ID
    8. Create config file:
       mkdir -p ~/.config/claude_usage
       echo '{"session_token": "YOUR_TOKEN", "organization_id": "YOUR_ORG_ID"}' > ~/.config/claude_usage/config.json
    """
  end
end
