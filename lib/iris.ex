defmodule Iris do
  @moduledoc """
  Handles RPC requests, delegating to Iris.RPC
  """

  defdelegate process_call(mfa, opts_key), to: Iris.RPC
  defdelegate process_call(mfa, opts_key, assigns), to: Iris.RPC
end
