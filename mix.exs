defmodule FlightTracker.MixProject do
  use Mix.Project

  def project do
    [
      app: :flight_tracker,
      version: "0.1.0",
      elixir: "~> 1.19",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_options: compiler_options(),
      test_coverage: test_coverage()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {FlightTracker.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:commanded, "~> 1.4"},
      {:jason, "~> 1.4"},
      {:typed_structor, "~> 0.6"},
      {:timex, "~> 3.7"},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false}
    ]
  end

  defp compiler_options do
    [
      warnings_as_errors: true
    ]
  end

  defp test_coverage do
    [
      summary: [threshold: 80]
    ]
  end
end
