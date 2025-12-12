defmodule ClaudeUsageWidget.Formatter do
  @moduledoc """
  Formats usage data for display in short or verbose mode.
  """

  def format(usage_data, mode \\ :short)

  def format(usage_data, :short) do
    five_hour = format_percentage(get_daily_usage(usage_data))
    weekly = format_percentage(get_weekly_usage(usage_data))

    "5h: #{five_hour} / 7d: #{weekly}"
  end

  def format(usage_data, :verbose) do
    daily = get_daily_usage(usage_data)
    weekly = get_weekly_usage(usage_data)
    sonnet = get_sonnet_usage(usage_data)

    daily_reset = format_reset_time(get_daily_reset(usage_data))
    weekly_reset = format_reset_time(get_weekly_reset(usage_data))
    sonnet_reset = format_reset_time(get_sonnet_reset(usage_data))

    """
    5-hour usage: #{String.pad_leading(format_percentage(daily), 6)} (resets: #{daily_reset})
    Weekly usage: #{String.pad_leading(format_percentage(weekly), 6)} (resets: #{weekly_reset})
    Sonnet usage: #{String.pad_leading(format_percentage(sonnet), 6)} (#{sonnet_reset})
    """
    |> String.trim()
  end

  def format(usage_data, :argos) do
    short_output = format(usage_data, :short)
    verbose_output = format(usage_data, :verbose)

    """
    #{short_output} | size=9 iconName=computer
    ---
    #{verbose_output}
    """
    |> String.trim()
  end

  defp get_daily_usage(data) do
    get_in(data, ["five_hour", "utilization"]) || 0.0
  end

  defp get_weekly_usage(data) do
    get_in(data, ["seven_day", "utilization"]) || 0.0
  end

  defp get_sonnet_usage(data) do
    get_in(data, ["seven_day_sonnet", "utilization"]) || 0.0
  end

  defp get_daily_reset(data) do
    get_in(data, ["five_hour", "resets_at"])
  end

  defp get_weekly_reset(data) do
    get_in(data, ["seven_day", "resets_at"])
  end

  defp get_sonnet_reset(data) do
    get_in(data, ["seven_day_sonnet", "resets_at"])
  end

  defp format_percentage(value) when is_number(value) do
    :erlang.float_to_binary(value, decimals: 0) <> "%"
  end

  defp format_percentage(_), do: "0.0%"

  defp format_reset_time(nil), do: "no reset scheduled"

  defp format_reset_time(timestamp) when is_binary(timestamp) do
    case DateTime.from_iso8601(timestamp) do
      {:ok, datetime, _offset} ->
        Calendar.strftime(datetime, "%Y-%m-%d %H:%M UTC")

      {:error, _} ->
        timestamp
    end
  end

  defp format_reset_time(timestamp) when is_integer(timestamp) do
    case DateTime.from_unix(timestamp) do
      {:ok, datetime} ->
        Calendar.strftime(datetime, "%Y-%m-%d %H:%M UTC")

      {:error, _} ->
        "unknown"
    end
  end

  defp format_reset_time(_), do: "unknown"
end
