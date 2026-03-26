defmodule FlightTracker.App.Aggregates.Aircraft do
  @moduledoc """
  Maintains the state of a specific aircraft based on its ICAO address.
  """
  @behaviour Commanded.Aggregates.Aggregate

  use TypedStructor

  alias FlightTracker.App.Commands.{
    IdentifyAircraftByAllCall,
    IdentifyAircraftByCallsign,
    IdentifyAircraftBySquawk,
    UpdateAirbornePosition,
    UpdateAirborneVelocity,
    UpdateSurfacePosition
  }

  alias FlightTracker.App.Events.{
    AircraftIdentified,
    EmergencyStatusUpdated,
    PositionUpdated,
    SquawkCodeSet,
    VelocityUpdated
  }

  alias __MODULE__, as: ModuleState

  typed_structor do
    @typedoc """
    Represents an aircraft. Includes only the minimal data required for command context.
    See `FlightTracer.App.Projectors.Aircraft` for the full available aircraft data.
    """
    field :icao_address, String.t(), enforce: true
    field :squawk_code, non_neg_integer()
    field :callsign, String.t()
    field :flight_id, String.t()
    field :is_emergency, boolean(), default: false
  end

  #
  # Command Handling
  #

  @impl true
  def execute(%ModuleState{} = state, %IdentifyAircraftByCallsign{} = cmd)
      when is_nil(state.icao_address) or state.callsign != cmd.callsign do
    evt = %AircraftIdentified{
      icao_address: cmd.icao_address,
      callsign: cmd.callsign,
      flight_id: cmd.flight_id,
      aircraft_id: cmd.aircraft_id,
      generated_ts: cmd.generated_ts
    }

    {:ok, evt}
  end

  def execute(_state, %IdentifyAircraftByCallsign{} = _cmd), do: {:ok, []}

  def execute(%ModuleState{} = _state, %UpdateSurfacePosition{} = cmd) do
    evts = [
      update_position(cmd.icao_address, true, cmd),
      %VelocityUpdated{
        icao_address: cmd.icao_address,
        ground_speed: cmd.ground_speed,
        track: cmd.track,
        is_on_ground: true,
        generated_ts: cmd.generated_ts
      }
    ]

    {:ok, evts}
  end

  def execute(%ModuleState{} = state, %UpdateAirbornePosition{} = cmd) do
    evts = [
      update_position(cmd.icao_address, false, cmd)
      | List.wrap(update_emergency_status(state, cmd))
    ]

    {:ok, evts}
  end

  def execute(%ModuleState{} = _state, %UpdateAirborneVelocity{} = cmd) do
    evt = %VelocityUpdated{
      icao_address: cmd.icao_address,
      ground_speed: cmd.ground_speed,
      track: cmd.track,
      vertical_rate: cmd.vertical_rate,
      is_on_ground: false,
      generated_ts: cmd.generated_ts
    }

    {:ok, evt}
  end

  def execute(%ModuleState{} = state, %IdentifyAircraftBySquawk{} = cmd) do
    ident_evt =
      if is_nil(state.icao_address) or state.flight_id != cmd.flight_id do
        %AircraftIdentified{
          icao_address: cmd.icao_address,
          is_on_ground: cmd.is_on_ground,
          flight_id: cmd.flight_id,
          aircraft_id: cmd.aircraft_id,
          generated_ts: cmd.generated_ts
        }
      else
        nil
      end

    squawk_evt =
      if state.squawk_code != cmd.squawk_code do
        %SquawkCodeSet{
          icao_address: cmd.icao_address,
          squawk_code: cmd.squawk_code,
          generated_ts: cmd.generated_ts
        }
      else
        nil
      end

    emer_evt = update_emergency_status(state, cmd)

    {:ok, List.wrap(ident_evt) ++ List.wrap(squawk_evt) ++ List.wrap(emer_evt)}
  end

  def execute(%ModuleState{} = state, %IdentifyAircraftByAllCall{} = cmd)
      when is_nil(state.icao_address) or state.flight_id != cmd.flight_id do
    evt = %AircraftIdentified{
      icao_address: cmd.icao_address,
      is_on_ground: cmd.is_on_ground,
      flight_id: cmd.flight_id,
      aircraft_id: cmd.aircraft_id,
      generated_ts: cmd.generated_ts
    }

    {:ok, evt}
  end

  def execute(_state, %IdentifyAircraftByAllCall{} = _cmd), do: {:ok, []}

  #
  # Event Handling
  #

  @impl true
  def apply(%ModuleState{} = state, %AircraftIdentified{} = evt) do
    %ModuleState{
      state
      | icao_address: evt.icao_address,
        callsign: evt.callsign,
        flight_id: evt.flight_id
    }
  end

  def apply(%ModuleState{} = state, %PositionUpdated{} = evt) do
    %ModuleState{
      state
      | icao_address: evt.icao_address
    }
  end

  def apply(%ModuleState{} = state, %VelocityUpdated{} = evt) do
    %ModuleState{
      state
      | icao_address: evt.icao_address
    }
  end

  def apply(%ModuleState{} = state, %EmergencyStatusUpdated{} = evt) do
    %ModuleState{
      state
      | icao_address: evt.icao_address,
        is_emergency: evt.is_emergency
    }
  end

  def apply(%ModuleState{} = state, %SquawkCodeSet{} = evt) do
    %ModuleState{
      state
      | icao_address: evt.icao_address,
        squawk_code: evt.squawk_code
    }
  end

  # Generates a PositionUpdated event. Supports common fields found in a position update command.
  @spec update_position(String.t(), boolean(), map()) :: PositionUpdated.t()
  defp update_position(
         icao_address,
         is_on_ground,
         %{altitude: alt, latitude: lat, longitude: lon, generated_ts: ts}
       ) do
    %PositionUpdated{
      icao_address: icao_address,
      altitude: alt,
      latitude: lat,
      longitude: lon,
      is_on_ground: is_on_ground,
      generated_ts: ts
    }
  end

  # Generates an EmergencyStatusUpdated event only if the status has changed
  @spec update_emergency_status(ModuleState.t(), map()) :: EmergencyStatusUpdated.t() | nil
  defp update_emergency_status(
         %ModuleState{is_emergency: curr_emer} = _state,
         %{icao_address: adr, is_emergency: new_emer, generated_ts: ts}
       )
       when curr_emer != new_emer do
    %EmergencyStatusUpdated{
      icao_address: adr,
      is_emergency: new_emer,
      generated_ts: ts
    }
  end

  defp update_emergency_status(_state, _cmd), do: nil
end
