defmodule FlightTracker.App.Services.AppService do
  @moduledoc """
  Provides a central entrypoint into the application that gateways must go through to dispatch
  commands. Handles mapping of incoming data to commands and command dispatch.
  """
  alias FlightTracker.App.Application
  alias FlightTracker.App.Commands

  @doc """
  Maps aircraft data to a command and dispatches it to the proper aircraft aggregate.

  See documentation for FlightTracker.App.Services.DataMapper.basestation_sbs_to_map/1 for
  expected map structure.
  """
  @spec update_aircraft(map()) :: :ok | {:error, term()}
  def update_aircraft(data) do
    case to_command(data) do
      :no_op -> :ok
      cmd -> Application.dispatch(cmd)
    end
  end

  @doc false
  @spec to_command(map()) :: struct() | :no_op
  def to_command(%{transmission_type: "1"} = data) do
    %Commands.IdentifyAircraftByCallsign{
      icao_address: data.icao_address,
      callsign: data.callsign,
      flight_id: data.flight_id,
      aircraft_id: data.aircraft_id,
      generated_ts: data.datetime_generated
    }
  end

  def to_command(%{transmission_type: "2"} = data) do
    %Commands.UpdateSurfacePosition{
      icao_address: data.icao_address,
      altitude: data.altitude,
      ground_speed: data.ground_speed,
      track: data.track,
      latitude: data.latitude,
      longitude: data.longitude,
      generated_ts: data.datetime_generated
    }
  end

  def to_command(%{transmission_type: "3"} = data) do
    %Commands.UpdateAirbornePosition{
      icao_address: data.icao_address,
      altitude: data.altitude,
      latitude: data.latitude,
      longitude: data.longitude,
      is_emergency: data.emergency_flag,
      generated_ts: data.datetime_generated
    }
  end

  def to_command(%{transmission_type: "4"} = data) do
    %Commands.UpdateAirborneVelocity{
      icao_address: data.icao_address,
      ground_speed: data.ground_speed,
      track: data.track,
      vertical_rate: data.vertical_rate,
      generated_ts: data.datetime_generated
    }
  end

  def to_command(%{transmission_type: "6"} = data) do
    %Commands.IdentifyAircraftBySquawk{
      icao_address: data.icao_address,
      squawk_code: data.squawk_code,
      is_emergency: data.emergency_flag,
      is_on_ground: data.on_ground_flag,
      flight_id: data.flight_id,
      aircraft_id: data.aircraft_id,
      generated_ts: data.datetime_generated
    }
  end

  def to_command(%{transmission_type: "8"} = data) do
    %Commands.IdentifyAircraftByAllCall{
      icao_address: data.icao_address,
      is_on_ground: data.on_ground_flag,
      flight_id: data.flight_id,
      aircraft_id: data.aircraft_id,
      generated_ts: data.datetime_generated
    }
  end

  def to_command(_data), do: :no_op
end
