defmodule IrisTest do
  use Iris.Test.Helper
  @doc """
  Simply delegates `process_call`'s to Iris.RPC module.
  @assigns, @opts declared in Iris.Test.Helper
  """

  test "process_call/2 is delegated correctly" do
    assert_ok Iris.process_call ["TestModule", "test_public", ["bar"]], :public
  end

  test "process_call/3  is delegated correctly" do
    assert_ok Iris.process_call ["TestModule", "test_assigns", ["bar"]], :private, @assigns
  end
end
