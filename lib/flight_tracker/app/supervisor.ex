defmodule FlightTracker.App.Supervisor do
  use Supervisor

  alias FlightTracker.App

  @doc """
  Called by parent application supervisor on startup
  """
  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    children = [
      # Application
      App.Application

      # TODO: Projectors

      # TODO: Gateways
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
