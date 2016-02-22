defmodule Iris.Test.Assertions do
  @moduledoc """
    Unwraps the authentication results and assert the tuple starts with :ok, or :error
  """
  require ExUnit.Assertions

  defmacro pass, do: ExUnit.Assertions.assert true

  defmacro assert_ok(arg) do
    quote do
      case Tuple.to_list(unquote(arg)) do
        [:ok|_] -> pass
        [:error| [msg |t]] -> flunk
      end
    end
  end

  defmacro refute_ok(arg) do
    quote do
      case Tuple.to_list(unquote(arg)) do
        [:ok| [msg |t]] -> flunk
        [:error|_] -> pass
      end
    end
  end
end
