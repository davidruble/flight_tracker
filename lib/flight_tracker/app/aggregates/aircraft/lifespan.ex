defmodule FlightTracker.App.Aggregates.Aircraft.Lifespan do
  @moduledoc """
  Defines the lifespan of an Aircraft aggregate by specifying when to stop it.
  """
  @behaviour Commanded.Aggregates.AggregateLifespan

  @inactivity_timeout_mins 5

  @impl true
  def after_command(_cmd), do: :timer.minutes(@inactivity_timeout_mins)

  @impl true
  def after_event(_evt), do: :timer.minutes(@inactivity_timeout_mins)

  @impl true
  def after_error(_err), do: :stop
end
