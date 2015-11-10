defmodule Iris do
  @moduledoc """
  Handles RPC requests, delegating to Iris.RPC
  Iris returns either an {:ok, result} | {:error, "Invalid Call"}.

  By default, Iris traps all exceptions, To enable exceptions to raise, specify the following config:
  ```
  config :iris, Iris,
    debug: true
  ```
  """

  defdelegate process_call(mfa, opts_key), to: Iris.RPC
  defdelegate process_call(mfa, opts_key, assigns), to: Iris.RPC
end
