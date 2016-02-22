defmodule Iris.RPCTest do
  use Iris.Test.Helper
  @doc """
  @assigns, @opts declared in Iris.Test.Helper
  """

  @public_args ["TestModule", "test_public", ["bar"]]
  @public_parsed_args {:"Elixir.Iris.Test.TestModule", :test_public, ["bar"]}

  @private_args ["TestModule", "test_private", ["food"]]
  @private_parsed_args {:"Elixir.Iris.Test.TestModule", :test_private, ["food"]}

  test "process_call/2 succeeds" do
    res = Iris.RPC.process_call @public_args, :public
    assert {:ok, "foo bar", @public_parsed_args} == res
    res = Iris.RPC.process_call @private_args, :private
    assert {:ok, "bar food", @private_parsed_args} == res
  end

  test "process_call/2 succeeds without prefix" do
    res = Iris.RPC.process_call ["Elixir.Iris.Test.TestModule", "test_public", ["bar"]], :no_prefix
    assert {:ok, "foo bar", {Iris.Test.TestModule, :test_public, ["bar"]}} == res
  end

  test "process_call/2 fails" do
    refute_ok Iris.RPC.process_call nil, nil
    refute_ok Iris.RPC.process_call ["Enum", "test_public", ["bar"]], :public
    refute_ok Iris.RPC.process_call [nil, "test_public", ["bar"]], :public
    refute_ok Iris.RPC.process_call ["TestModule", nil, ["bar"]], :public
    refute_ok Iris.RPC.process_call ["TestModule", "test_public", nil], :public
    refute_ok Iris.RPC.process_call @public_args, :private
    refute_ok Iris.RPC.process_call @private_args, :public
  end

  test "process_call/3 succeeds" do
    res = Iris.RPC.process_call ["TestModule", "test_assigns", ["bar"]], :private, @assigns
    assert {:ok, "hellobar", {Iris.Test.TestModule, :test_assigns, [%{text: "hello"}, "bar"]}} == res
  end

  test "process_call/3 fails" do
    refute_ok Iris.RPC.process_call nil, nil, %{text: "hello"}
    refute_ok Iris.RPC.process_call ["Enum", "test_assigns", ["bar"]], :private, @assigns
    refute_ok Iris.RPC.process_call [nil, "test_assigns", ["bar"]], :private, @assigns
    refute_ok Iris.RPC.process_call ["TestModule", nil, ["bar"]], :private, @assigns
    refute_ok Iris.RPC.process_call ["TestModule", nil, "bar"], :private, @assigns
    refute_ok Iris.RPC.process_call ["TestModule", "test_assigns", nil], :private, @assigns
  end

  test "parse_input/2 suceeds" do
    result = Iris.RPC.parse_input @public_args, @opts
    assert_ok result
    {_, {module, _, _}}  = result
    assert module == :"Elixir.Iris.Test.TestModule"

    # Here we show how @opts passed to parse_input affects the parsing of the module, in particular, a lack of :mod_prefix
    result = Iris.RPC.parse_input @public_args, nil
    assert_ok result
    {_, {module, _, _}}  = result
    assert module == :"TestModule"
  end

  test "parse_input/2 fails" do
    refute_ok Iris.RPC.parse_input(["TestModule", "test_public"], @opts)
    refute_ok Iris.RPC.parse_input(["NotAModule", "test_public", ["bar"]], @opts)
    refute_ok Iris.RPC.parse_input("TestModule", @opts)
  end

  test "parse_input/2 without mod_prefix" do
    result = Iris.RPC.parse_input ["Elixir.Iris.Test.TestModule", "test_public", ["bar"]], @opts_no_prefix
    assert_ok result
    {_, {module, fun, args}}  = result
    assert module == :"Elixir.Iris.Test.TestModule"
    assert fun == :test_public
    assert args == ["bar"]
  end

  test "dispatch/4 succeeds" do
    assert Iris.RPC.dispatch :"Elixir.Iris.Test.TestModule", :test_public, ["bar"], @opts
  end

  test "dispatch/4 errors" do
    assert_raise(Iris.PermissionError, fn -> Iris.RPC.dispatch(:"Elixir.Iris.Test.TestModule", :does_not_exist, ["bar"], @opts) end)
  end

  test "call_allowed?/3 returns true if MFA is allowed" do
    assert Iris.RPC.call_allowed? :"Elixir.Iris.Test.TestModule", :test_public, ["bar"], @opts
  end

  test "call_allowed?/3 returns false if MFA is disallowed" do
    refute Iris.RPC.call_allowed? :"Elixir.Iris.Test.TestModule", :test_public, ["bar", "food"], @opts
    refute Iris.RPC.call_allowed? :"Elixir.Iris.Test.TestModule", :test_private, ["food"], @opts
    refute Iris.RPC.call_allowed? :users, :test_public, ["bar"], @opts
  end

  test "call_allowed?/3 returns false if any args are nil" do
    refute Iris.RPC.call_allowed? nil, :test_public, ["bar"], @opts
    refute Iris.RPC.call_allowed? :"Elixir.Iris.Test.TestModule", nil, ["bar"], @opts
    refute Iris.RPC.call_allowed? :"Elixir.Iris.Test.TestModule", :test_public, nil, @opts
  end
end
