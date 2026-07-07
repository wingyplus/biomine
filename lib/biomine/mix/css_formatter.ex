defmodule Biomine.Mix.CssFormatter do
  @moduledoc """
  Mix formatter plugin for CSS files.
  """

  @behaviour Mix.Tasks.Format

  @extensions ~w(.css)

  @impl Mix.Tasks.Format
  def features(_opts) do
    [extensions: @extensions]
  end

  @impl Mix.Tasks.Format
  def format(contents, _opts) do
    case Biomine.format_css(contents) do
      {:ok, formatted} -> formatted
      {:error, {:parse_error, diagnostics}} -> Mix.raise(parse_error_message(diagnostics))
    end
  end

  defp parse_error_message([%{message: message} | _]) do
    "could not format CSS: #{message}"
  end
end
