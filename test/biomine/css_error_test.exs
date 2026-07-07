defmodule Biomine.CSSErrorTest do
  use ExUnit.Case, async: true

  test "format_css parse error" do
    assert {:error, {:parse_error, diagnostics}} = Biomine.format_css("a {")

    assert [%{message: message, span: %{start: start, end: stop}} | _] = diagnostics
    assert is_binary(message)
    assert message != ""
    assert is_integer(start)
    assert is_integer(stop)
    assert start <= stop
  end

  test "format_css rejects Tailwind directives by default" do
    assert {:error, {:parse_error, diagnostics}} =
             Biomine.format_css("""
             a {
               @apply text-navy-100;
             }
             """)

    assert [%{message: message} | _] = diagnostics
    assert message == "Tailwind-specific syntax is disabled."
  end
end
