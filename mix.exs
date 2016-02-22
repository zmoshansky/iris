defmodule Iris.Mixfile do
  use Mix.Project

  def project do
    [
      app: :iris,
      version: "0.3.0",
      elixir: "~> 1.0",
      elixirc_paths: elixirc_paths(Mix.env),
      description: description,
      package: package,
      deps: deps
    ]
  end

  def application do
    [applications: applications(Mix.env)]
  end

  #
  # Private
  #

  # Specifies which paths to compile per environment
  defp elixirc_paths(:test), do: ["test/support"] ++ elixirc_paths(:prod)
  defp elixirc_paths(_),     do: ["lib"]


  defp applications(:test) do
    [:logger] ++ applications(:prod)
  end

  defp applications(_) do
    []
  end

  defp deps do
    [
      {:ex_doc, ">=0.1.0", only: [:dev, :test]},
        {:earmark, ">= 0.0.0", only: [:dev, :test]},
    ]
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Zachary Moshansky"],
      licenses: ["BSD 3-Clause"],
      links: %{"GitHub" => "https://github.com/zmoshansky/iris"}
    ]
  end

  defp description do
    """
      A simple RPC system that filters calls based on Module, Function, Arity.
    """
  end

end
