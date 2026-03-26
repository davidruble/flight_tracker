defmodule FlightTracker.App.Projectors.AircraftTest do
  use ExUnit.Case

  alias FlightTracker.App.Events
  alias FlightTracker.App.Projectors.Aircraft

  @ten_sec 600

  setup_all do
    Aircraft.init([])
    [table: :aircraft]
  end

  setup context do
    :ets.delete_all_objects(context.table)
    :ok
  end

  test "handles AircraftIdentified for unknown aircraft", %{table: table} do
    icao = "AC82EC"

    evt = %Events.AircraftIdentified{
      icao_address: icao,
      callsign: "CALL123",
      is_on_ground: true,
      flight_id: "FLIGHT123",
      aircraft_id: "AIR123",
      generated_ts: System.system_time(:second)
    }

    :ok = Aircraft.handle(evt, %{})

    assert lookup_aircraft(table, icao) ==
             %Aircraft{
               icao_address: icao,
               callsign: evt.callsign,
               is_on_ground: evt.is_on_ground,
               flight_id: evt.flight_id,
               aircraft_id: evt.aircraft_id,
               updated_ts: evt.generated_ts
             }
  end

  test "updates existing aircraft on AircraftIdentified", %{table: table} do
    icao = "AC82EC"

    init_state = %Aircraft{
      icao_address: icao,
      squawk_code: 1200,
      flight_id: "FLIGHT234",
      updated_ts: System.system_time(:second) - @ten_sec
    }

    :ets.insert(table, {icao, init_state})

    evt = %Events.AircraftIdentified{
      icao_address: icao,
      callsign: "CALL123",
      is_on_ground: true,
      flight_id: "FLIGHT123",
      aircraft_id: "AIR123",
      generated_ts: System.system_time(:second)
    }

    :ok = Aircraft.handle(evt, %{})

    assert lookup_aircraft(table, icao) == %Aircraft{
             icao_address: icao,
             squawk_code: init_state.squawk_code,
             callsign: evt.callsign,
             is_on_ground: evt.is_on_ground,
             flight_id: evt.flight_id,
             aircraft_id: evt.aircraft_id,
             updated_ts: evt.generated_ts
           }
  end

  test "updates existing aircraft on EmergencyStatusUpdated", %{table: table} do
    icao = "AC82EC"

    init_state = %Aircraft{
      icao_address: icao,
      is_on_ground: true,
      updated_ts: System.system_time(:second) - @ten_sec
    }

    :ets.insert(table, {icao, init_state})

    evt = %Events.EmergencyStatusUpdated{
      icao_address: icao,
      is_emergency: true,
      generated_ts: System.system_time(:second)
    }

    :ok = Aircraft.handle(evt, %{})

    assert lookup_aircraft(table, icao) == %Aircraft{
             icao_address: icao,
             is_on_ground: init_state.is_on_ground,
             is_emergency: evt.is_emergency,
             updated_ts: evt.generated_ts
           }
  end

  test "updates existing aircraft on PositionUpdated", %{table: table} do
    icao = "AC82EC"

    init_state = %Aircraft{
      icao_address: icao,
      aircraft_id: "AIR123",
      updated_ts: System.system_time(:second) - @ten_sec
    }

    :ets.insert(table, {icao, init_state})

    evt = %Events.PositionUpdated{
      icao_address: icao,
      altitude: 800,
      latitude: 30.500,
      longitude: -100.250,
      is_on_ground: false,
      generated_ts: System.system_time(:second)
    }

    :ok = Aircraft.handle(evt, %{})

    assert lookup_aircraft(table, icao) == %Aircraft{
             icao_address: icao,
             aircraft_id: init_state.aircraft_id,
             altitude: evt.altitude,
             latitude: evt.latitude,
             longitude: evt.longitude,
             is_on_ground: evt.is_on_ground,
             updated_ts: evt.generated_ts
           }
  end

  test "updates existing aircraft on SquawkCodeSet", %{table: table} do
    icao = "AC82EC"

    init_state = %Aircraft{
      icao_address: icao,
      squawk_code: 1200,
      is_on_ground: true,
      updated_ts: System.system_time(:second) - @ten_sec
    }

    :ets.insert(table, {icao, init_state})

    evt = %Events.SquawkCodeSet{
      icao_address: icao,
      squawk_code: 7500,
      generated_ts: System.system_time(:second)
    }

    :ok = Aircraft.handle(evt, %{})

    assert lookup_aircraft(table, icao) == %Aircraft{
             icao_address: icao,
             is_on_ground: init_state.is_on_ground,
             squawk_code: evt.squawk_code,
             updated_ts: evt.generated_ts
           }
  end

  test "updates existing aircraft on VelocityUpdated", %{table: table} do
    icao = "AC82EC"

    init_state = %Aircraft{
      icao_address: icao,
      callsign: "CALL123",
      latitude: 30.500,
      longitude: -100.250,
      updated_ts: System.system_time(:second) - @ten_sec
    }

    :ets.insert(table, {icao, init_state})

    evt = %Events.VelocityUpdated{
      icao_address: icao,
      ground_speed: 500.0,
      track: 270.5,
      vertical_rate: 2048,
      is_on_ground: false,
      generated_ts: System.system_time(:second)
    }

    :ok = Aircraft.handle(evt, %{})

    assert lookup_aircraft(table, icao) == %Aircraft{
             icao_address: icao,
             callsign: init_state.callsign,
             latitude: init_state.latitude,
             longitude: init_state.longitude,
             ground_speed: evt.ground_speed,
             track: evt.track,
             vertical_rate: evt.vertical_rate,
             is_on_ground: evt.is_on_ground,
             updated_ts: evt.generated_ts
           }
  end

  test "leverages the most recent timestamp when events come out of order", %{table: table} do
    icao = "AC82EC"

    init_state = %Aircraft{
      icao_address: icao,
      updated_ts: System.system_time(:second) + @ten_sec
    }

    :ets.insert(table, {icao, init_state})

    evt = %Events.EmergencyStatusUpdated{
      icao_address: icao,
      is_emergency: true,
      generated_ts: System.system_time(:second) - @ten_sec
    }

    :ok = Aircraft.handle(evt, %{})

    assert lookup_aircraft(table, icao) == %Aircraft{
             icao_address: icao,
             is_emergency: evt.is_emergency,
             updated_ts: init_state.updated_ts
           }
  end

  defp lookup_aircraft(table, icao) do
    case :ets.lookup(table, icao) do
      [{^icao, %Aircraft{} = state}] -> state
      [] -> :not_found
    end
  end
end
