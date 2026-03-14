defmodule FlightTracker.App.Events.EmergencyStatusUpdated do
  @moduledoc """
  Indicates whether or not there is currently an emergency on the aircraft.
  """
  use TypedStructor

  @derive Jason.Encoder
  typed_structor do
    @typedoc "Represents an aircraft's emergency state."
    field :icao_address, String.t(), enforce: true
    field :is_emergency, boolean(), default: false
    field :generated_ts, DateTime.t()
  end
end
