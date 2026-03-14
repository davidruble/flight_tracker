defmodule FlightTracker.App.Commands.IdentifyAircraftByAllCall do
  @moduledoc """
  Identifies an aircraft by its all call reply. Triggered by a request from Air Traffic Control
  and also broadcast automatically. Maps to SBS-1 MSG type 8 (All Call Reply).
  """
  use TypedStructor

  typed_structor enforce: true do
    @typedoc "Represents an aircraft's all call information."
    field :icao_address, String.t()
    field :is_on_ground, boolean()
    field :flight_id, String.t()
    field :aircraft_id, String.t()
    field :generated_ts, DateTime.t()
  end
end
