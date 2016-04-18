defmodule Iris.RPC do
  require Logger
  @moduledoc """
  process_call[/2|/3] both exist so `assigns` doesn't carry a penalty if not used,
  or limit the ability to have `assigns=nil` | `assigns=[]`, etc which may convey important information.
  """

  defmacrop debug_exception?(exception) do
    config =  Application.get_env(:iris, Iris)
    if config do
      case config[:error] do
        :log -> quote do: Logger.error("Iris: #{inspect(unquote(exception))}")
        :raise -> quote do
            stacktrace = System.stacktrace
            reraise unquote(exception), stacktrace
          end
        # Uses should explicitly use `:ignore`
        _ -> nil
      end
    end
  end

  @doc """
  mfa is a list of: module, function, args.
  module & function are strings, args is a list

  Note: module strings must be fully qualified, including "Elixir."
  ex.) `Elixir.Iris.RPC`

  Use the mix config option `mod_prefix` to prepend a string to the
  module string before converting to an atom.
  ex.) mod_prefix: "Elixir.Iris", mfa = ["RPC", "parse_input", [mfa, opts]]

  opts_key is the key used in your mix config, allowing multiple configs.
  """
  @spec process_call(list, atom) :: {:ok, any, {atom, atom, list}} | {:error, atom, {atom, atom, list}} | {:error, atom, list} | no_return
  def process_call(mfa, opts_key) do
    opts = Application.get_env(:iris, opts_key)

    case parse_input(mfa, opts) do
      {:error, msg} -> {:error, msg, mfa}
      {:ok, good_input} ->
        try do
          {module, fun, args} = good_input
          {:ok, dispatch(module, fun, args, opts), good_input}
        rescue exception ->
          debug_exception?(exception)
          {:error, Iris.Errors.processing, good_input}
        end
    end
  end

  @doc """
  mfa is a list of: module, function, args.
  module & function are strings, args is a list

  Note: module strings must be fully qualified, including "Elixir."
  ex.) `Elixir.Iris.RPC`

  Use the mix config option `mod_prefix` to prepend a string to the
  module string before converting to an atom.
  ex.) mod_prefix: "Elixir.Iris", mfa = ["RPC", "parse_input", [mfa, opts]]

  opts_key is the key used in your mix config, allowing multiple configs.
  assigns is any type of data to pass along to the mfa being called. It is
  prepended to the args list before calling dispatch/4.
  """
  @spec process_call(list, atom, any) :: {:ok, any, {atom, atom, list}} | {:error, atom, {atom, atom, list}} | {:error, atom, list} | no_return
  def process_call(mfa, opts_key, assigns) do
    opts = Application.get_env(:iris, opts_key)

    case parse_input(mfa, opts) do
      {:error, msg} -> {:error, msg, mfa}
      {:ok, good_input} ->
        try do
          {module, fun, args} = good_input
          args = [assigns] ++ args
          {:ok, dispatch(module, fun, args, opts), {module, fun, args}}
        rescue exception ->
          debug_exception?(exception)
          {module, fun, args} = good_input
          args = [assigns] ++ args
          {:error, Iris.Errors.processing, {module, fun, args}}
        end
    end
  end

  @doc """
  The results of parse_input can be trusted to be in the form of {module, function, args}.
  It will also raise/{:error...} if the items do not match the spec.
  """
  @spec parse_input(list, list) :: {:ok, {atom, atom, list}} | {:error, atom} | no_return
  def parse_input(mfa, opts) do
    try do
      {module_str, fun_str, args} = List.to_tuple mfa

      module = if opts[:mod_prefix] do
        String.to_existing_atom(opts[:mod_prefix] <> module_str)
      else
        String.to_existing_atom(module_str)
      end

      fun = String.to_existing_atom(fun_str)

      if(!is_list(args)) do
       raise ArgumentError, message: "args must be a list, found #{inspect args}"
      end

      {:ok, {module, fun, args}}
    rescue exception ->
      debug_exception?(exception)
      {:error, Iris.Errors.parsing}
    end
  end

  @spec dispatch(atom, atom, list, list) :: any | no_return
  def dispatch(module, fun, args, opts) do
    if call_allowed?(module, fun, args, opts) do
      apply(module, fun, args)
    else
      raise Iris.PermissionError, message: "Call #{inspect module}:#{inspect fun}:#{inspect args} not allowed"
    end
  end

  @spec call_allowed?(atom, atom, list, list) :: boolean
  def call_allowed?(module, fun, args, _) when is_nil(module) or is_nil(fun) or is_nil(args), do: false
  def call_allowed?(module, fun, args, opts) do
    try do
      opts[:allow]
      |> Dict.get(module)
      |> Dict.get(fun)
      |> Enum.member?(length(args))
    rescue
      _ -> false
    end
  end

end

defmodule Iris.PermissionError do
  defexception message: "Call not allowed"
end

defmodule Iris.Errors do
  def parsing(), do: :parsing
  def processing(), do: :processing
end