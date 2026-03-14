defmodule FlightTracker.App.Events.SquawkCodeSet do
  @moduledoc """
  Indicates that the aircraft's squawk code has been set or updated.
  """
  use TypedStructor

  @derive Jason.Encoder
  typed_structor do
    @typedoc "The squawk code has been set or updated."
    field :icao_address, String.t(), enforce: true
    field :squawk_code, non_neg_integer(), enforce: true
    field :generated_ts, DateTime.t()
  end
end
