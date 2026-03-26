defmodule Mix.Tasks.GetAircraftState do
  @moduledoc """
  Mix task to help get the state of an aircraft from `:ets` by its ICAO address.

  Intended ONLY for use when running within `iex`.

  Run from within `iex` with `Mix.Task.rerun("get_aircraft_state", ["ABCDEF"])`.

  If you WERE to run from cmd line, it would be with `mix get_aircraft_state ABCDEF`.
  """
  use Mix.Task

  require Logger

  @table :aircraft

  @impl true
  def run(args) do
    case args do
      [icao | _] ->
        case :ets.lookup(@table, icao) do
          [{^icao, state}] -> IO.inspect(state)
          _ -> Logger.warning("ICAO #{icao} not found")
        end

      _ ->
        Logger.error("Please provide an ICAO address")
    end
  end
end
