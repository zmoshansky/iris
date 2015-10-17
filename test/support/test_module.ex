defmodule Iris.Test.TestModule do

  def test_public(arg0), do: "foo " <> arg0
  def test_private(arg0), do: "bar " <> arg0
  def test_assigns(assigns, arg0), do: assigns.text <> arg0

end
