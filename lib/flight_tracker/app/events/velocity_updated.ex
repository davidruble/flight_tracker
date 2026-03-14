defmodule FlightTracker.App.Events.VelocityUpdated do
  @moduledoc """
  Indicates that an aircraft's velocity has been updated. Can be airborne or on ground.
  """
  use TypedStructor

  @derive Jason.Encoder
  typed_structor do
    @typedoc "The aircraft's velocity has been updated."
    field :icao_address, String.t(), enforce: true
    field :ground_speed, float()
    field :track, float()
    field :vertical_rate, integer(), default: 0
    field :is_on_ground, boolean(), default: false
    field :generated_ts, DateTime.t()
  end
end
