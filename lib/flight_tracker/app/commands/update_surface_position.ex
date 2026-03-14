defmodule FlightTracker.App.Commands.UpdateSurfacePosition do
  @moduledoc """
  Updates an aircraft's ground position and speed. Only triggered if the aircraft's squat switch is
  active. Maps to SBS-1 MSG type 2 (ES Surface Position Message).
  """
  use TypedStructor

  typed_structor enforce: true do
    @typedoc "Represents a surface position change."
    field :icao_address, String.t()
    field :altitude, non_neg_integer()
    field :ground_speed, float()
    field :track, float()
    field :latitude, float()
    field :longitude, float()
    field :generated_ts, DateTime.t()
  end
end
