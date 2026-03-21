defmodule FlightTracker.App.Services.DataMapper do
  @moduledoc """
  Provides helpers to map incoming data to more useful formats.
  """
  require Logger

  # Fields and their positions matching the BaseStation SBS-1 format. Note this excludes the msg
  # type field since this application only supports transmission messages ("MSG") and ignores that
  # field.
  @sbs_fields [
    :transmission_type,
    :session_id,
    :aircraft_id,
    :icao_address,
    :flight_id,
    :date_generated,
    :time_generated,
    :date_logged,
    :time_logged,
    :callsign,
    :altitude,
    :ground_speed,
    :track,
    :latitude,
    :longitude,
    :vertical_rate,
    :squawk_code,
    :squawk_alert_flag,
    :emergency_flag,
    :ident_flag,
    :on_ground_flag
  ]

  @datetime_format "%Y/%m/%d %H:%M:%S.%L"

  @doc """
  Converts a single row of BaseStation SBS-1 formatted data into a map with parsed types.
  There should be 22 fields.
  """
  @spec basestation_sbs_to_map(list(String.t())) :: {:ok, map()} | {:error, :malformed_data}
  def basestation_sbs_to_map(["MSG" | data]) when length(data) == 21 do
    data_map = Enum.map(data, &String.trim/1) |> then(&Enum.zip(@sbs_fields, &1)) |> Map.new()
    generated_ts_str = "#{data_map.date_generated} #{data_map.time_generated}"

    with {:ok, generated_ts} <- parse_datetime(generated_ts_str),
         {:ok, alt} <- to_int(data_map.altitude),
         {:ok, speed} <- to_float(data_map.ground_speed),
         {:ok, track} <- to_float(data_map.track),
         {:ok, lat} <- to_float(data_map.latitude),
         {:ok, long} <- to_float(data_map.longitude),
         {:ok, vert_rate} <- to_int(data_map.vertical_rate),
         {:ok, squawk} <- to_int(data_map.squawk_code) do
      data_map =
        %{
          data_map
          | altitude: empty_to_nil(alt),
            ground_speed: empty_to_nil(speed),
            track: empty_to_nil(track),
            latitude: empty_to_nil(lat),
            longitude: empty_to_nil(long),
            vertical_rate: empty_to_nil(vert_rate),
            squawk_code: empty_to_nil(squawk),
            squawk_alert_flag: to_bool(data_map.squawk_alert_flag),
            emergency_flag: to_bool(data_map.emergency_flag),
            ident_flag: to_bool(data_map.ident_flag),
            on_ground_flag: to_bool(data_map.on_ground_flag)
        }
        |> Map.put(:datetime_generated, generated_ts)
        |> Map.drop([:date_generated, :time_generated, :date_logged, :time_logged])

      {:ok, data_map}
    else
      :error ->
        Logger.error("Failed to parse a number in the data")
        {:error, :malformed_data}

      {:error, reason} ->
        Logger.error("Failed to parse a date or time in the data: #{inspect(reason)}")
        {:error, :malformed_data}
    end
  end

  def basestation_sbs_to_map(_data), do: {:error, :malformed_data}

  @spec parse_datetime(String.t()) :: {:ok, DateTime.t()} | {:error, term()}
  defp parse_datetime(str) do
    with {:ok, naive_time} <- Timex.parse(str, @datetime_format, :strftime),
         utc_time <- Timex.to_datetime(naive_time) do
      {:ok, utc_time}
    end
  end

  @spec to_int(String.t()) :: {:ok, integer() | :empty} | :error
  defp to_int(""), do: {:ok, :empty}

  defp to_int(str) do
    case Integer.parse(str) do
      {val, _} -> {:ok, val}
      :error -> :error
    end
  end

  @spec to_float(String.t()) :: {:ok, float() | :empty} | :error
  defp to_float(""), do: {:ok, :empty}

  defp to_float(str) do
    case Float.parse(str) do
      {val, _} -> {:ok, val}
      :error -> :error
    end
  end

  @spec to_bool(String.t()) :: boolean()
  defp to_bool(str) when is_nil(str) or str == "" or str == "0", do: false
  defp to_bool(_str), do: true

  @spec empty_to_nil(:empty | number()) :: nil | number()
  defp empty_to_nil(:empty), do: nil
  defp empty_to_nil(val), do: val
end
