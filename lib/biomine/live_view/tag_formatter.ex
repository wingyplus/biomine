if Code.ensure_loaded?(Phoenix.LiveView.HTMLFormatter.TagFormatter) do
  defmodule Biomine.LiveView.TagFormatter do
    @moduledoc """
    A `Phoenix.LiveView.HTMLFormatter.TagFormatter` implementation that formats
    the contents of `<script>` tags with Biomine.

    This is useful for formatting [colocated
    hooks](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.ColocatedHook.html)
    embedded in `.heex` templates and `~H` sigils.

    ## Setup

    Add it as a `:tag_formatters` entry alongside `Phoenix.LiveView.HTMLFormatter`
    in your `.formatter.exs` file:

    ```elixir
    [
      plugins: [Phoenix.LiveView.HTMLFormatter],
      tag_formatters: %{script: Biomine.LiveView.TagFormatter},
      inputs: [
        "{mix,.formatter}.exs",
        "{config,lib,test}/**/*.{ex,exs,heex}"
      ]
    ]
    ```

    Formatter options can be passed under `biomine: [js: ...]`, same as
    `Biomine.Mix.JsFormatter`:

    ```elixir
    [
      plugins: [Phoenix.LiveView.HTMLFormatter],
      tag_formatters: %{script: Biomine.LiveView.TagFormatter},
      biomine: [
        js: [quote_style: :single, semicolons: :as_needed]
      ],
      inputs: [
        "{mix,.formatter}.exs",
        "{config,lib,test}/**/*.{ex,exs,heex}"
      ]
    ]
    ```
    """

    @behaviour Phoenix.LiveView.HTMLFormatter.TagFormatter

    require Logger

    @impl true
    def render_tag({"script", _attrs, content}, opts) do
      biomine_opts = opts |> Keyword.get(:biomine, []) |> Keyword.get(:js, [])

      case Biomine.format_js(content, biomine_opts) do
        {:ok, formatted} ->
          {:ok, String.trim(formatted)}

        {:error, reason} ->
          Logger.error("could not format script tag with Biomine: #{inspect(reason)}")
          :skip
      end
    end

    def render_tag({_tag_name, _attrs, _content}, _opts), do: :skip
  end
end
