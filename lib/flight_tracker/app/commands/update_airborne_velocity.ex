defmodule FlightTracker.App.Commands.UpdateAirborneVelocity do
  @moduledoc """
  Updates an aircraft's airborne velocity. Maps to SBS-1 MSG type 4 (ES Airborne Velocity Message).
  """
  use TypedStructor

  typed_structor enforce: true do
    @typedoc "Represents an airborne velocity change."
    field :icao_address, String.t()
    field :ground_speed, float()
    field :track, float()
    field :vertical_rate, integer()
    field :generated_ts, DateTime.t()
  end
end
