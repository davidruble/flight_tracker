defmodule FlightTracker.Application do
  use Application

  alias FlightTracker.App

  # TODO: Parse command line argument specifying which gateway to use and pass to supervisor
  @impl true
  def start(_type, _args) do
    children = [
      # Starts a worker by calling: FlightTracker.Worker.start_link(arg)
      {App.Supervisor, nil}
    ]

    opts = [strategy: :one_for_one, name: FlightTracker.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
