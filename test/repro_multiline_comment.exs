# Reproduction: multiline (block) comments inside <script>/<style> gain
# indentation every time `mix format` runs with Biomine.LiveView.TagFormatter.
#
# Run with: elixir test/repro_multiline_comment.exs <path/to/libbiomine_native.so>
#
# This script avoids Hex deps: it loads the locally built NIF directly and
# simulates the part of Phoenix.LiveView.HTMLFormatter (v1.2.5,
# html_algebra.ex `to_algebra/2` for @languages) that matters:
#
#   1. The *raw* tag body from the template (already indented by the previous
#      run) is passed to `render_tag/2`.
#   2. The returned text is dedented by its minimum indentation and then nested
#      two spaces deeper than the tag.

[so_path] = System.argv()

defmodule Biomine.Native do
  @so_path so_path |> String.replace_suffix(".so", "")
  @on_load :load
  def load, do: :erlang.load_nif(String.to_charlist(@so_path), 0)
  def format_js(_, _), do: :erlang.nif_error(:nif_not_loaded)
  def format_css(_, _), do: :erlang.nif_error(:nif_not_loaded)
end

# Minimal stand-ins so lib/biomine/live_view/tag_formatter.ex compiles as-is.
defmodule Phoenix.LiveView.HTMLFormatter.TagFormatter do
  @callback render_tag({String.t(), map(), String.t()}, keyword()) :: {:ok, String.t()} | :skip
end

defmodule Biomine do
  # Same defaults Biomine applies via NimbleOptions.
  @defaults [indent_style: :space, indent_width: 2]
  def format_js(src, opts), do: Biomine.Native.format_js(src, Keyword.merge(@defaults, opts))
  def format_css(src, opts), do: Biomine.Native.format_css(src, Keyword.merge(@defaults, opts))
end

Code.require_file("../lib/biomine/live_view/tag_formatter.ex", __DIR__)

defmodule FakeHEEx do
  @tag_indent 2

  # One `mix format` pass over:
  #   <div>
  #     <script>...</script>
  #   </div>
  def format_pass(tag, template) do
    [_, body] = Regex.run(~r/<#{tag}>\n(.*)\n  <\/#{tag}>/s, template)

    {:ok, formatted} = Biomine.LiveView.TagFormatter.render_tag({tag, %{}, body}, [])

    lines = String.split(formatted, "\n")

    min =
      lines
      |> Enum.reject(&(String.trim(&1) == ""))
      |> Enum.map(&(byte_size(&1) - byte_size(String.trim_leading(&1))))
      |> Enum.min(fn -> 0 end)

    pad = String.duplicate(" ", @tag_indent + 2)

    body =
      lines
      |> Enum.map(fn
        "" -> ""
        line -> pad <> binary_part(line, min, byte_size(line) - min)
      end)
      |> Enum.join("\n")

    "<div>\n  <#{tag}>\n#{body}\n  </#{tag}>\n</div>\n"
  end
end

run = fn tag, initial ->
  IO.puts("===== <#{tag}> =====")

  Enum.reduce(1..4, initial, fn i, template ->
    next = FakeHEEx.format_pass(tag, template)
    IO.puts("--- after pass #{i} (stable? #{next == template}) ---")
    IO.write(next)
    next
  end)
end

run.("script", """
<div>
  <script>
    /*
      multiline
      comment
    */
    let x = 1;
  </script>
</div>
""")

run.("style", """
<div>
  <style>
    /*
      multiline
      comment
    */
    a { color: red; }
  </style>
</div>
""")
