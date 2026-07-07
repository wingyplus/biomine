defmodule Biomine.Mix.CssFormatterTest do
  use ExUnit.Case, async: true

  test "features includes the CSS extension" do
    assert [extensions: extensions] = Biomine.Mix.CssFormatter.features([])

    assert ".css" in extensions
  end

  test "format formats CSS" do
    assert Biomine.Mix.CssFormatter.format("a{color:red}", []) == "a {\n  color: red;\n}\n"
  end

  test "format raises on parse errors" do
    assert_raise Mix.Error, ~r/could not format CSS/, fn ->
      Biomine.Mix.CssFormatter.format("a {", [])
    end
  end
end
