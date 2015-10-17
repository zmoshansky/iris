defmodule Iris.Test.Helper do
  @doc false
  defmacro __using__(_opts) do
    quote do
      use ExUnit.Case, async: true
      import Iris.Test.Assertions

      @opts [
        allow: %{
          :"Elixir.Iris.Test.TestModule" => %{test_public: [1]},
        },
        mod_prefix: "Elixir.Iris.Test."
      ]
      @opts_no_prefix [
        allow: %{
          :"Elixir.Iris.Test.TestModule" => %{test_public: [1]},
        }
      ]

      @assigns %{text: "hello"}
    end
  end
end
