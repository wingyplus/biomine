defmodule Biomine.Mix.CssFormatterTest do
  use ExUnit.Case, async: true

  test "features includes the CSS extension" do
    assert [extensions: extensions] = Biomine.Mix.CssFormatter.features([])

    assert ".css" in extensions
  end

  test "format formats CSS" do
    assert Biomine.Mix.CssFormatter.format("a{color:red}", []) == "a {\n  color: red;\n}\n"
  end

  test "format passes Biomine options from the formatter configuration" do
    assert Biomine.Mix.CssFormatter.format(~s(a{content:"hi"}),
             biomine: [css: [quote_style: :single]]
           ) ==
             "a {\n  content: 'hi';\n}\n"
  end

  test "format only uses the CSS Biomine options" do
    assert Biomine.Mix.CssFormatter.format(~s(a{content:"hi"}),
             biomine: [js: [quote_style: :invalid], css: [quote_style: :single]]
           ) ==
             "a {\n  content: 'hi';\n}\n"
  end

  test "format raises on parse errors" do
    assert_raise Mix.Error, ~r/could not format CSS/, fn ->
      Biomine.Mix.CssFormatter.format("a {", [])
    end
  end

  test "format raises on invalid Biomine options" do
    assert_raise Mix.Error, "invalid Biomine formatter option", fn ->
      Biomine.Mix.CssFormatter.format("a{color:red}", biomine: [css: [quote_style: :invalid]])
    end
  end
end
