defmodule Biomine.JSErrorTest do
  use ExUnit.Case, async: true

  test "format_js parse error" do
    assert {:error, :parse_error} = Biomine.format_js("funtion f(")
  end
end
