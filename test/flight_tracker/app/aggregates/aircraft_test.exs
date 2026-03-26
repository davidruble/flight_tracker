defmodule FlightTracker.App.Aggregates.AircraftTest do
  use ExUnit.Case

  require Logger

  alias FlightTracker.App.Aggregates.Aircraft
  alias FlightTracker.App.Commands
  alias FlightTracker.App.Events

  test "identifies a new aircraft by callsign" do
    icao = "AC82EC"
    callsign = "CALL123"
    flight_id = "FLIGHT123"
    aircraft_id = "AIR123"
    generated_ts = System.system_time(:second)

    initial_state = %Aircraft{
      icao_address: nil
    }

    cmds = [
      %Commands.IdentifyAircraftByCallsign{
        icao_address: icao,
        callsign: callsign,
        flight_id: flight_id,
        aircraft_id: aircraft_id,
        generated_ts: generated_ts
      }
    ]

    %{state: _state, events: evts} = apply_commands(initial_state, cmds)

    assert evts == [
             %Events.AircraftIdentified{
               icao_address: icao,
               callsign: callsign,
               flight_id: flight_id,
               aircraft_id: aircraft_id,
               generated_ts: generated_ts
             }
           ]
  end

  test "emergency status is set and unset by commands that impact it" do
    icao = "AC82EC"
    squawk = 1200
    flight_id = "FLIGHT123"
    aircraft_id = "AIR123"
    latitude = 29.534
    longitude = -98.469
    altitude = 809
    ts = System.system_time(:second)

    initial_state = %Aircraft{
      icao_address: nil
    }

    cmds = [
      %Commands.IdentifyAircraftBySquawk{
        icao_address: icao,
        squawk_code: squawk,
        is_emergency: true,
        is_on_ground: false,
        flight_id: flight_id,
        aircraft_id: aircraft_id,
        generated_ts: ts
      },
      %Commands.UpdateAirbornePosition{
        icao_address: icao,
        altitude: altitude,
        latitude: latitude,
        longitude: longitude,
        is_emergency: false,
        generated_ts: ts
      }
    ]

    %{state: _state, events: evts} = apply_commands(initial_state, cmds)

    assert evts == [
             %Events.AircraftIdentified{
               icao_address: icao,
               flight_id: flight_id,
               aircraft_id: aircraft_id,
               generated_ts: ts
             },
             %Events.SquawkCodeSet{
               icao_address: icao,
               squawk_code: squawk,
               generated_ts: ts
             },
             %Events.EmergencyStatusUpdated{
               icao_address: icao,
               is_emergency: true,
               generated_ts: ts
             },
             %Events.PositionUpdated{
               icao_address: icao,
               altitude: altitude,
               latitude: latitude,
               longitude: longitude,
               is_on_ground: false,
               generated_ts: ts
             },
             %Events.EmergencyStatusUpdated{
               icao_address: icao,
               is_emergency: false,
               generated_ts: ts
             }
           ]
  end

  test "ignores identification for aircraft already known" do
    icao = "AC82EC"
    squawk = 1200
    callsign = "CALL123"
    flight_id = "FLIGHT123"
    aircraft_id = "AIR123"
    is_emergency = false
    is_on_ground = false

    initial_state = %Aircraft{
      icao_address: icao,
      squawk_code: squawk,
      callsign: callsign,
      flight_id: flight_id,
      is_emergency: is_emergency
    }

    cmds = [
      %Commands.IdentifyAircraftByCallsign{
        icao_address: icao,
        callsign: callsign,
        flight_id: flight_id,
        aircraft_id: aircraft_id,
        generated_ts: System.system_time(:second)
      },
      %Commands.IdentifyAircraftBySquawk{
        icao_address: icao,
        squawk_code: squawk,
        is_emergency: is_emergency,
        is_on_ground: is_on_ground,
        flight_id: flight_id,
        aircraft_id: aircraft_id,
        generated_ts: System.system_time(:second)
      },
      %Commands.IdentifyAircraftByAllCall{
        icao_address: icao,
        is_on_ground: is_on_ground,
        flight_id: flight_id,
        aircraft_id: aircraft_id,
        generated_ts: System.system_time(:second)
      }
    ]

    %{state: _state, events: evts} = apply_commands(initial_state, cmds)

    assert evts == []
  end

  test "track the path of an active, initially unknown aircraft" do
    icao = "AC82EC"
    flight_id = "FLIGHT123"
    aircraft_id = "AIR123"

    takeoff = %{
      latitude: 29.534,
      longitude: -98.469,
      altitude: 809,
      track: 90.0,
      speed: 150.0,
      ts: System.system_time(:second)
    }

    flying = %{
      latitude: 32.45,
      longitude: -99.73,
      altitude: 32000,
      track: 270.0,
      speed: 500.0,
      vert_rate: 2048,
      ts: System.system_time(:second)
    }

    initial_state = %Aircraft{
      icao_address: nil
    }

    cmds = [
      %Commands.UpdateSurfacePosition{
        icao_address: icao,
        altitude: takeoff.altitude,
        ground_speed: takeoff.speed,
        track: takeoff.track,
        latitude: takeoff.latitude,
        longitude: takeoff.longitude,
        generated_ts: takeoff.ts
      },
      %Commands.IdentifyAircraftByAllCall{
        icao_address: icao,
        is_on_ground: true,
        flight_id: flight_id,
        aircraft_id: aircraft_id,
        generated_ts: takeoff.ts
      },
      %Commands.UpdateAirborneVelocity{
        icao_address: icao,
        ground_speed: flying.speed,
        track: flying.track,
        vertical_rate: flying.vert_rate,
        generated_ts: flying.ts
      },
      %Commands.UpdateAirbornePosition{
        icao_address: icao,
        altitude: flying.altitude,
        latitude: flying.latitude,
        longitude: flying.longitude,
        is_emergency: false,
        generated_ts: flying.ts
      }
    ]

    %{state: state, events: evts} = apply_commands(initial_state, cmds)

    assert evts == [
             %Events.PositionUpdated{
               icao_address: icao,
               altitude: takeoff.altitude,
               latitude: takeoff.latitude,
               longitude: takeoff.longitude,
               is_on_ground: true,
               generated_ts: takeoff.ts
             },
             %Events.VelocityUpdated{
               icao_address: icao,
               ground_speed: takeoff.speed,
               track: takeoff.track,
               is_on_ground: true,
               generated_ts: takeoff.ts
             },
             %Events.AircraftIdentified{
               icao_address: icao,
               is_on_ground: true,
               flight_id: flight_id,
               aircraft_id: aircraft_id,
               generated_ts: takeoff.ts
             },
             %Events.VelocityUpdated{
               icao_address: icao,
               ground_speed: flying.speed,
               track: flying.track,
               vertical_rate: flying.vert_rate,
               is_on_ground: false,
               generated_ts: flying.ts
             },
             %Events.PositionUpdated{
               icao_address: icao,
               altitude: flying.altitude,
               latitude: flying.latitude,
               longitude: flying.longitude,
               is_on_ground: false,
               generated_ts: flying.ts
             }
           ]

    assert state == %Aircraft{
             icao_address: icao,
             squawk_code: nil,
             callsign: nil,
             flight_id: flight_id,
             is_emergency: false
           }
  end

  defp apply_commands(%Aircraft{} = initial_state, cmds) do
    List.foldl(cmds, %{state: initial_state, events: []}, fn cmd, acc ->
      case Aircraft.execute(acc.state, cmd) do
        {:ok, []} ->
          acc

        {:ok, [_ | _] = evts} ->
          Enum.reduce(evts, acc, &apply_event/2)

        {:ok, evt} ->
          apply_event(evt, acc)

        _ ->
          Logger.error("Failed to execute command #{IO.inspect(cmd)}.")
          acc
      end
    end)
  end

  defp apply_event(evt, acc) do
    new_state = Aircraft.apply(acc.state, evt)
    %{state: new_state, events: acc.events ++ [evt]}
  end
end
