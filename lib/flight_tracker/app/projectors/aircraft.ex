defmodule FlightTracker.App.Projectors.Aircraft do
  @moduledoc """
  Projects aircraft data to `:ets` for external services (like a UI) to read from.
  """
  use Commanded.Event.Handler,
    application: FlightTracker.App.Application,
    name: __MODULE__,
    start_from: :current

  use TypedStructor

  alias FlightTracker.App.Events.{
    AircraftIdentified,
    EmergencyStatusUpdated,
    PositionUpdated,
    SquawkCodeSet,
    VelocityUpdated
  }

  alias __MODULE__, as: AircraftData

  typed_structor do
    @typedoc """
    Represents the current known state of a specific aircraft.

    Notes:
      - `:icao_address` is a unique, permanent, 6 character hex identifier assigned by the International
        Civil Aviation Organization (ICAO) to an aircraft.
      - `:squawk_code` is a 4-digit transponder code assigned by Air Traffic Control. This can be an
        aircraft identifier or a standard/emergency code.
      - `:altitude` is barometric relative to sea level (1013.2mb). Measured in feet.
      - `:latitude` is positive for N, negative for S
      - `:longitude` is positive for W, negative for E
      - `:ground_speed` is speed relative to the ground and not true airspeed. Measured in knots.
      - `:track` is not the heading but the real direction the plane is moving, taking drift into
        consideration. Measured in clockwise degrees from true north.
      - `:vertical_rate` is the speed at which the aircraft is ascending/descending. Usually only
        at 24-64 ft resolution. Measured in ft/min. Positive for ascending, negative for descending.
      - `:updated_ts` is stored as unix epoch seconds
    """
    field :icao_address, String.t(), enforce: true
    field :squawk_code, non_neg_integer()
    field :callsign, String.t()
    field :flight_id, String.t()
    field :aircraft_id, String.t()
    field :altitude, non_neg_integer()
    field :latitude, float()
    field :longitude, float()
    field :ground_speed, float()
    field :track, float()
    field :vertical_rate, integer()
    field :is_on_ground, boolean(), default: false
    field :is_emergency, boolean(), default: false
    field :updated_ts, non_neg_integer()
  end

  @table :aircraft

  @impl true
  def init(config) do
    :ets.new(@table, [:named_table, :set, :public, write_concurrency: :auto])
    {:ok, config}
  end

  @impl true
  def handle(%AircraftIdentified{} = evt, _metadata) do
    aircraft = get_aircraft_by_icao(evt.icao_address)

    updated_aircraft =
      %AircraftData{
        aircraft
        | callsign: evt.callsign,
          is_on_ground: evt.is_on_ground,
          flight_id: evt.flight_id,
          aircraft_id: evt.aircraft_id
      }
      |> update_ts(evt)

    :ets.insert(@table, {evt.icao_address, updated_aircraft})
    :ok
  end

  def handle(%EmergencyStatusUpdated{} = evt, _metadata) do
    aircraft = get_aircraft_by_icao(evt.icao_address)

    updated_aircraft =
      %AircraftData{aircraft | is_emergency: evt.is_emergency}
      |> update_ts(evt)

    :ets.insert(@table, {evt.icao_address, updated_aircraft})
    :ok
  end

  def handle(%PositionUpdated{} = evt, _metadata) do
    aircraft = get_aircraft_by_icao(evt.icao_address)

    updated_aircraft =
      %AircraftData{
        aircraft
        | altitude: evt.altitude,
          latitude: evt.latitude,
          longitude: evt.longitude,
          is_on_ground: evt.is_on_ground
      }
      |> update_ts(evt)

    :ets.insert(@table, {evt.icao_address, updated_aircraft})
    :ok
  end

  def handle(%SquawkCodeSet{} = evt, _metadata) do
    aircraft = get_aircraft_by_icao(evt.icao_address)

    updated_aircraft =
      %AircraftData{aircraft | squawk_code: evt.squawk_code}
      |> update_ts(evt)

    :ets.insert(@table, {evt.icao_address, updated_aircraft})
    :ok
  end

  def handle(%VelocityUpdated{} = evt, _metadata) do
    aircraft = get_aircraft_by_icao(evt.icao_address)

    updated_aircraft =
      %AircraftData{
        aircraft
        | ground_speed: evt.ground_speed,
          track: evt.track,
          vertical_rate: evt.vertical_rate,
          is_on_ground: evt.is_on_ground
      }
      |> update_ts(evt)

    :ets.insert(@table, {evt.icao_address, updated_aircraft})
    :ok
  end

  # Fetches the currently known data for an aircraft from the DB based on its ICAO
  @spec get_aircraft_by_icao(String.t()) :: AircraftData.t()
  defp get_aircraft_by_icao(icao) do
    case :ets.lookup(@table, icao) do
      [{^icao, %AircraftData{} = state}] ->
        state

      [] ->
        # If we haven't seen this aircraft yet we at least have its ICAO address
        %AircraftData{icao_address: icao}
    end
  end

  # In case events get processed out of order for whatever reason, we want ensure updated_ts is most recent
  @spec update_ts(AircraftData.t(), struct()) :: AircraftData.t()
  defp update_ts(%AircraftData{updated_ts: state_ts} = aircraft, %{generated_ts: evt_ts}) do
    updated_ts = if is_nil(state_ts), do: evt_ts, else: max(state_ts, evt_ts)
    %AircraftData{aircraft | updated_ts: updated_ts}
  end
end
