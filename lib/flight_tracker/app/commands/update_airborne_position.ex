defmodule FlightTracker.App.Commands.UpdateAirbornePosition do
  @moduledoc """
  Updates an aircraft's airborne position. Maps to SBS-1 MSG type 3 (ES Airborne Position Message).
  """
  use TypedStructor

  typed_structor enforce: true do
    @typedoc "Represents a airborne position change."
    field :icao_address, String.t()
    field :altitude, non_neg_integer()
    field :latitude, float()
    field :longitude, float()
    field :is_emergency, boolean()
    field :generated_ts, DateTime.t()
  end
end
