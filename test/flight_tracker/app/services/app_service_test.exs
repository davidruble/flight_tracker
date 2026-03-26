defmodule FlightTracker.App.Services.AppServiceTest do
  use ExUnit.Case, async: false

  alias FlightTracker.App.Commands
  alias FlightTracker.App.Services.AppService

  test "to_command handles MSG type 1" do
    data = generate_data("1")

    cmd = %Commands.IdentifyAircraftByCallsign{
      icao_address: data.icao_address,
      callsign: data.callsign,
      flight_id: data.flight_id,
      aircraft_id: data.aircraft_id,
      generated_ts: data.datetime_generated
    }

    assert AppService.to_command(data) == cmd
  end

  test "to_command handles MSG type 2" do
    data = generate_data("2")

    cmd = %Commands.UpdateSurfacePosition{
      icao_address: data.icao_address,
      altitude: data.altitude,
      ground_speed: data.ground_speed,
      track: data.track,
      latitude: data.latitude,
      longitude: data.longitude,
      generated_ts: data.datetime_generated
    }

    assert AppService.to_command(data) == cmd
  end

  test "to_command handles MSG type 3" do
    data = generate_data("3")

    cmd = %Commands.UpdateAirbornePosition{
      icao_address: data.icao_address,
      altitude: data.altitude,
      latitude: data.latitude,
      longitude: data.longitude,
      is_emergency: data.emergency_flag,
      generated_ts: data.datetime_generated
    }

    assert AppService.to_command(data) == cmd
  end

  test "to_command handles MSG type 4" do
    data = generate_data("4")

    cmd = %Commands.UpdateAirborneVelocity{
      icao_address: data.icao_address,
      ground_speed: data.ground_speed,
      track: data.track,
      vertical_rate: data.vertical_rate,
      generated_ts: data.datetime_generated
    }

    assert AppService.to_command(data) == cmd
  end

  test "to_command handles MSG type 6" do
    data = generate_data("6")

    cmd = %Commands.IdentifyAircraftBySquawk{
      icao_address: data.icao_address,
      squawk_code: data.squawk_code,
      is_emergency: data.emergency_flag,
      is_on_ground: data.on_ground_flag,
      flight_id: data.flight_id,
      aircraft_id: data.aircraft_id,
      generated_ts: data.datetime_generated
    }

    assert AppService.to_command(data) == cmd
  end

  test "to_command handles MSG type 8" do
    data = generate_data("8")

    cmd = %Commands.IdentifyAircraftByAllCall{
      icao_address: data.icao_address,
      is_on_ground: data.on_ground_flag,
      flight_id: data.flight_id,
      aircraft_id: data.aircraft_id,
      generated_ts: data.datetime_generated
    }

    assert AppService.to_command(data) == cmd
  end

  test "to_command ignores unhandled MSG types" do
    data = generate_data("7")
    assert AppService.to_command(data) == :no_op
  end

  defp generate_data(transmission_type) do
    %{
      transmission_type: transmission_type,
      aircraft_id: "AIRCRAFT123",
      icao_address: "AC82EC",
      flight_id: "FLIGHT123",
      callsign: "CALL123",
      altitude: 1000,
      ground_speed: 200.0,
      track: 90.0,
      latitude: 30.0,
      longitude: -100.0,
      vertical_rate: 2048,
      squawk_code: 1200,
      squawk_alert_flag: false,
      emergency_flag: false,
      ident_flag: false,
      on_ground_flag: false,
      datetime_generated: DateTime.utc_now()
    }
  end
end
