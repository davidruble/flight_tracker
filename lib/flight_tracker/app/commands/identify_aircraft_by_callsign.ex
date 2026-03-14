defmodule FlightTracker.App.Commands.IdentifyAircraftByCallsign do
  @moduledoc """
  Identifies an aircraft by its callsign. Broadcasted from the aircraft, and can be sent at any
  time, even after other messages. Maps to SBS-1 MSG type 1 (ES Identification and Category).
  """
  use TypedStructor

  typed_structor enforce: true do
    @typedoc "Represents an aircraft's callsign information."
    field :icao_address, String.t()
    field :callsign, String.t()
    field :flight_id, String.t()
    field :aircraft_id, String.t()
    field :generated_ts, DateTime.t()
  end
end
