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
        App.Application,

        # Projectors
        App.Projectors.Aircraft
      ]
      |> append_gateways(args)

    Supervisor.init(children, strategy: :one_for_one)
  end

  @spec append_gateways(list(Supervisor.module_spec()), term()) :: list(Supervisor.module_spec())
  defp append_gateways(children, args) do
    case args do
      [filename: filename] when is_binary(filename) ->
        children ++ [{App.Gateways.FileInjector, filename}]

      _ ->
        # TODO: Start gateway that hooks into live data
        children
    end
  end
end
