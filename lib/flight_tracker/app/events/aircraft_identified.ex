defmodule FlightTracker.App.Events.AircraftIdentified do
  @moduledoc """
  Specifies that aircraft identification information has been processed. This can happen after
  other updates like position, or sometimes not at all.
  """
  use TypedStructor

  @derive Jason.Encoder
  typed_structor do
    @typedoc "An aircraft has been identified."
    field :icao_address, String.t(), enforce: true
    field :callsign, String.t()
    field :is_on_ground, boolean(), default: false
    field :flight_id, String.t()
    field :aircraft_id, String.t()
    field :generated_ts, non_neg_integer()
  end
end
