defmodule FlightTracker.App.Commands.IdentifyAircraftBySquawk do
  @moduledoc """
  Identifies an aircraft by its squawk code. Maps to SBS-1 MSG type 6 (Surveillance ID Message).
  """
  use TypedStructor

  typed_structor enforce: true do
    @typedoc "Represents an aircraft's squawk and emergency information."
    field :icao_address, String.t()
    field :squawk_code, non_neg_integer()
    field :is_emergency, boolean()
    field :is_on_ground, boolean()
    field :flight_id, String.t()
    field :aircraft_id, String.t()
    field :generated_ts, DateTime.t()
  end
end
