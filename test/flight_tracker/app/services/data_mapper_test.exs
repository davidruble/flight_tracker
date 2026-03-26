defmodule FlightTracker.App.Services.DataMapperTest do
  use ExUnit.Case

  alias FlightTracker.App.Services.DataMapper

  @transmission_type_idx 1
  @session_id_idx 2
  @aircraft_id_idx 3
  @icao_address_idx 4
  @flight_id_idx 5
  @date_generated_idx 6
  @time_generated_idx 7
  @callsign_idx 10
  @altitude_idx 11
  @squawk_idx 17

  @data_length 21

  test "fields are parsed and populated correctly" do
    data = sample_data()

    assert DataMapper.basestation_sbs_to_map(data) == {
             :ok,
             %{
               transmission_type: Enum.at(data, @transmission_type_idx),
               session_id: Enum.at(data, @session_id_idx),
               aircraft_id: Enum.at(data, @aircraft_id_idx),
               icao_address: Enum.at(data, @icao_address_idx),
               flight_id: Enum.at(data, @flight_id_idx),
               callsign: Enum.at(data, @callsign_idx),
               altitude: 28000,
               ground_speed: 460.2,
               track: 20.2,
               latitude: 53.0214,
               longitude: -2.913,
               vertical_rate: 64,
               squawk_code: 1200,
               squawk_alert_flag: false,
               emergency_flag: true,
               ident_flag: false,
               on_ground_flag: false,
               datetime_generated: DateTime.to_unix(~U[2026-03-20 15:02:10.756Z])
             }
           }
  end

  test "empty strings are handled gracefully" do
    # The only fields technically required for the parser are message id, date generated, and time generated
    data =
      empty_data()
      |> List.replace_at(@transmission_type_idx, "1")
      |> List.replace_at(@date_generated_idx, "2026/03/20")
      |> List.replace_at(@time_generated_idx, "02:05:10.000")

    assert DataMapper.basestation_sbs_to_map(data) == {
             :ok,
             %{
               transmission_type: Enum.at(data, @transmission_type_idx),
               session_id: Enum.at(data, @session_id_idx),
               aircraft_id: Enum.at(data, @aircraft_id_idx),
               icao_address: Enum.at(data, @icao_address_idx),
               flight_id: Enum.at(data, @flight_id_idx),
               callsign: Enum.at(data, @callsign_idx),
               altitude: nil,
               ground_speed: nil,
               track: nil,
               latitude: nil,
               longitude: nil,
               vertical_rate: nil,
               squawk_code: nil,
               squawk_alert_flag: false,
               emergency_flag: false,
               ident_flag: false,
               on_ground_flag: false,
               datetime_generated: DateTime.to_unix(~U[2026-03-20 02:05:10.000Z])
             }
           }
  end

  test "wrong number format generates an error" do
    data = sample_data()

    Enum.each(@altitude_idx..@squawk_idx, fn idx ->
      bad_data = List.replace_at(data, idx, "bad juju")
      assert DataMapper.basestation_sbs_to_map(bad_data) == {:error, :malformed_data}
    end)
  end

  test "wrong date format generates an error" do
    data =
      sample_data()
      |> List.replace_at(@date_generated_idx, "3-19-2026")
      |> List.replace_at(@time_generated_idx, "2:00 PM")

    assert DataMapper.basestation_sbs_to_map(data) == {:error, :malformed_data}
  end

  test "wrong data length generates an error" do
    data = ["MSG" | Enum.drop(sample_data(), 2)]
    assert DataMapper.basestation_sbs_to_map(data) == {:error, :malformed_data}
  end

  test "wrong message ID generates an error" do
    data = sample_data("SEL")
    assert DataMapper.basestation_sbs_to_map(data) == {:error, :malformed_data}
  end

  defp empty_data(message_id \\ "MSG"), do: [message_id | List.duplicate("", @data_length)]

  defp sample_data(message_id \\ "MSG") do
    [
      message_id,
      # transmission_type
      "1",
      # session_id
      "SES1",
      # aircraft_id
      "AIR1",
      # icao_address
      "AC82EC",
      # flight_id
      "FLY1",
      # date_generated
      "2026/03/20",
      # time_generated
      "15:02:10.756",
      # date_logged
      "2026/03/20",
      # time_logged
      "15:05:10.756",
      # callsign
      "CALL1",
      # altitude
      "28000",
      # ground_speed
      "460.2",
      # track
      "20.2",
      # latitude
      "53.0214",
      # longitude
      "-2.913",
      # vertical_rate
      "64",
      # squawk_code
      "1200",
      # squawk_alert_flag
      "0",
      # emergency_flag
      "-1",
      # ident_flag
      "0",
      # on_ground_flag
      ""
    ]
  end
end
