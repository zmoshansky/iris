defmodule Iris.RPCTest do
  use Iris.Test.Helper
  @doc """
  @assigns, @opts declared in Iris.Test.Helper
  """

  test "process_call/2 succeeds" do
    res = Iris.RPC.process_call ["TestModule", "test_public", ["bar"]], :public
    assert {:ok, "foo bar"} == res
    res = Iris.RPC.process_call ["TestModule", "test_private", ["food"]], :private
    assert {:ok, "bar food"} == res
  end

  test "process_call/2 succeeds without prefix" do
    res = Iris.RPC.process_call ["Elixir.Iris.Test.TestModule", "test_public", ["bar"]], :no_prefix
    assert {:ok, "foo bar"} == res
  end

  test "process_call/2 fails" do
    refute_ok Iris.RPC.process_call nil, nil
    refute_ok Iris.RPC.process_call ["Enum", "test_public", ["bar"]], :public
    refute_ok Iris.RPC.process_call [nil, "test_public", ["bar"]], :public
    refute_ok Iris.RPC.process_call ["TestModule", nil, ["bar"]], :public
    refute_ok Iris.RPC.process_call ["TestModule", "test_public", nil], :public
    refute_ok Iris.RPC.process_call ["TestModule", "test_public", ["bar"]], :private
    refute_ok Iris.RPC.process_call ["TestModule", "test_private", ["food"]], :public
  end

  test "process_call/3 succeeds" do
    res = Iris.RPC.process_call ["TestModule", "test_assigns", ["bar"]], :private, @assigns
    assert {:ok, "hellobar"} == res
  end

  test "process_call/3 fails" do
    refute_ok Iris.RPC.process_call nil, nil, %{text: "hello"}
    refute_ok Iris.RPC.process_call ["Enum", "test_assigns", ["bar"]], :private, @assigns
    refute_ok Iris.RPC.process_call [nil, "test_assigns", ["bar"]], :private, @assigns
    refute_ok Iris.RPC.process_call ["TestModule", nil, ["bar"]], :private, @assigns
    refute_ok Iris.RPC.process_call ["TestModule", "test_assigns", nil], :private, @assigns
  end

  test "parse_input/2 suceeds" do
    {module, fun, args}  = Iris.RPC.parse_input ["TestModule", "test_public", ["bar"]], @opts
    assert module == :"Elixir.Iris.Test.TestModule"
    assert fun == :test_public
    assert args == ["bar"]
  end

  test "parse_input/2 without mod_prefix" do
    {module, fun, args}  = Iris.RPC.parse_input ["Elixir.Iris.Test.TestModule", "test_public", ["bar"]], @opts_no_prefix
    assert module == :"Elixir.Iris.Test.TestModule"
    assert fun == :test_public
    assert args == ["bar"]
  end

  test "dispatch/4 succeeds" do
    assert Iris.RPC.dispatch :"Elixir.Iris.Test.TestModule", :test_public, ["bar"], @opts
  end

  test "dispatch/4 errors" do
    Iris.RPC.dispatch(:"Elixir.Iris.Test.TestModule", :does_not_exist, ["bar"], @opts)
    |> catch_error()
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
