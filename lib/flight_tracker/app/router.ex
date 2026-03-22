defmodule FlightTracker.App.Router do
  @moduledoc """
  Leverages Commanded's Router macros to configure which commands are sent to which aggregates.
  """
  use Commanded.Commands.Router

  alias FlightTracker.App.Aggregates.Aircraft

  alias FlightTracker.App.Commands.{
    IdentifyAircraftByAllCall,
    IdentifyAircraftByCallsign,
    IdentifyAircraftBySquawk,
    UpdateAirbornePosition,
    UpdateAirborneVelocity,
    UpdateSurfacePosition
  }

  identify(Aircraft, by: :icao_address, prefix: "aircraft-")

  dispatch(
    [
      IdentifyAircraftByAllCall,
      IdentifyAircraftByCallsign,
      IdentifyAircraftBySquawk,
      UpdateAirbornePosition,
      UpdateAirborneVelocity,
      UpdateSurfacePosition
    ],
    to: Aircraft,
    lifespan: Aircraft.Lifespan
  )
end
