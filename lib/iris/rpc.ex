defmodule Iris.RPC do

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
  @spec process_call(list, atom) :: {:ok, any} | {:error, binary} | no_return
  def process_call(mfa, opts_key) do
    opts = Application.get_env(:iris, opts_key)
    try do
      {module, fun, args} = parse_input(mfa, opts)
      {:ok, dispatch(module, fun, args, opts)}
    rescue
      exception ->
        stacktrace = System.stacktrace
        config =  Application.get_env(:iris, Iris)
        if config && config[:debug] do
          reraise exception, stacktrace
        else
          {:error, "Invalid Call"}
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
  @spec process_call(list, atom, any) :: {:ok, any} | {:error, binary} | no_return
  def process_call(mfa, opts_key, assigns) do
    opts = Application.get_env(:iris, opts_key)
    try do
      {module, fun, args} = parse_input(mfa, opts)
      {:ok, dispatch(module, fun, [assigns] ++ args, opts)}
    rescue
      exception ->
        stacktrace = System.stacktrace
        config =  Application.get_env(:iris, Iris)
        if config && config[:debug] do
          reraise exception, stacktrace
        else
          {:error, "Invalid Call"}
        end
    end
  end

  @spec parse_input(list, list) :: tuple
  def parse_input(mfa, opts) do
    {module_str, fun_str, args} = List.to_tuple mfa

    module = if opts[:mod_prefix] do
      String.to_existing_atom(opts[:mod_prefix] <> module_str)
    else
      String.to_existing_atom(module_str)
    end

    fun = String.to_existing_atom(fun_str)
    {module, fun, args}
  end

  @spec dispatch(atom, atom, list, list) :: any | no_return
  def dispatch(module, fun, args, opts) do
    if call_allowed?(module, fun, args, opts) do
      apply(module, fun, args)
    else
      raise PermissionError, message: "Call #{inspect module}:#{inspect fun}:#{inspect args} not allowed"
    end
  end

  @spec call_allowed?(atom, atom, list, list) :: boolean
  def call_allowed?(module, fun, args, _) when is_nil(module) or is_nil(fun) or is_nil(args), do: false
  def call_allowed?(module, fun, args, opts) do
    try do
      opts[:allow]
      |> Dict.get(module)
      |> Dict.get(fun)
      |> Enum.member? length(args)
    rescue
      _ -> false
    end
  end

end

defmodule PermissionError do
  defexception message: "Call not allowed"
end
