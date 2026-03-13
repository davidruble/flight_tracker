defmodule FlightTracker.App.Application do
  @moduledoc """
  Entry point into the Commanded application.
  """
  require Logger

  use Commanded.Application, otp_app: :flight_tracker

  router(FlightTracker.App.Router)

  @impl true
  def init(config) do
    Logger.info("Starting Flight Tracker App")
    {:ok, config}
  end
end
