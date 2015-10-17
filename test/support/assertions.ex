defmodule Iris.Test.Assertions do
  @moduledoc """
    Unwraps the authentication results and assert {:ok, _} | {:error, _}
  """
  require ExUnit.Assertions

  defmacro pass, do: ExUnit.Assertions.assert true

  defmacro assert_ok(arg) do
    quote do
      case unquote(arg) do
        {:ok, _} -> pass
        {:error, msg} -> flunk msg
      end
    end
  end

  defmacro refute_ok(arg) do
    quote do
      case unquote(arg) do
        {:ok, msg} -> flunk msg
        {:error, _} -> pass
      end
    end
  end
end
