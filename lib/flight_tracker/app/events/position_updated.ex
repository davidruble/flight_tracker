defmodule FlightTracker.App.Events.PositionUpdated do
  @moduledoc """
  Indicates that an aircraft's position and/or altitude has been updated.
  """
  use TypedStructor

  @derive Jason.Encoder
  typed_structor do
    @typedoc "The aircraft's position and/or altitude has been updated."
    field :icao_address, String.t(), enforce: true
    field :altitude, non_neg_integer()
    field :latitude, float()
    field :longitude, float()
    field :is_on_ground, boolean(), default: false
    field :generated_ts, DateTime.t()
  end
end
