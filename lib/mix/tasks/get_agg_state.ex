defmodule Mix.Tasks.GetAggState do
  @moduledoc """
  Mix task to help get the state of an aircraft aggregate by its ICAO address.

  Intended ONLY for use when running within `iex`.

  Run from within `iex` with `Mix.Task.rerun("get_agg_state", ["ABCDEF"])`.

  If you WERE to run from cmd line, it would be with `mix get_agg_state ABCDEF`.
  """
  use Mix.Task

  require Logger

  alias FlightTracker.App.Application
  alias FlightTracker.App.Aggregates.Aircraft
  alias Commanded.Aggregates.Aggregate

  @impl true
  def run(args) do
    case args do
      [icao | _] ->
        state = Aggregate.aggregate_state(Application, Aircraft, "aircraft-#{icao}")
        IO.inspect(state)

      _ ->
        Logger.error("Please provide an ICAO address")
    end
  end
end
