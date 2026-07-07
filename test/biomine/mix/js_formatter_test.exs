defmodule Biomine.Mix.JsFormatterTest do
  use ExUnit.Case, async: true

  test "features includes JavaScript and TypeScript extensions" do
    assert [extensions: extensions] = Biomine.Mix.JsFormatter.features([])

    assert ".js" in extensions
    assert ".jsx" in extensions
    assert ".ts" in extensions
    assert ".tsx" in extensions
  end

  test "format formats JavaScript" do
    assert Biomine.Mix.JsFormatter.format("let x=1", []) == "let x = 1;\n"
  end

  test "format passes Biomine options from the formatter configuration" do
    assert Biomine.Mix.JsFormatter.format("let x='hello'", biomine: [js: [quote_style: :single]]) ==
             "let x = 'hello';\n"
  end

  test "format only uses the JavaScript Biomine options" do
    assert Biomine.Mix.JsFormatter.format("let x='hello'",
             biomine: [js: [quote_style: :single], css: [quote_style: :invalid]]
           ) ==
             "let x = 'hello';\n"
  end

  test "format raises on parse errors" do
    assert_raise Mix.Error, ~r/could not format JavaScript\/TypeScript/, fn ->
      Biomine.Mix.JsFormatter.format("funtion f(", [])
    end
  end

  test "format raises on invalid Biomine options" do
    assert_raise Mix.Error, "invalid Biomine formatter option", fn ->
      Biomine.Mix.JsFormatter.format("let x=1", biomine: [js: [quote_style: :invalid]])
    end
  end
end
