defmodule Biomine.JSErrorTest do
  use ExUnit.Case, async: true

  test "format_js parse error" do
    assert {:error, {:parse_error, diagnostics}} = Biomine.format_js("funtion f(")

    assert [%{message: message, span: %{start: start, end: stop}} | _] = diagnostics
    assert is_binary(message)
    assert message != ""
    assert is_integer(start)
    assert is_integer(stop)
    assert start <= stop
  end
end
