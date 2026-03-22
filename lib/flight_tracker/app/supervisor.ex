defmodule FlightTracker.App.Supervisor do
  use Supervisor

  alias FlightTracker.App

  @doc """
  Called by parent application supervisor on startup
  """
  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init(args) do
    children =
      [
        # Application
        App.Application

        # TODO: Projectors
      ]
      |> append_gateways(args)

    Supervisor.init(children, strategy: :one_for_one)
  end

  defp append_gateways(children, args) do
    case args do
      [filename: filename] when is_binary(filename) ->
        [{App.Gateways.FileInjector, filename}] ++ children

      _ ->
        # TODO: Start gateway that hooks into live data
        children
    end
  end
end
