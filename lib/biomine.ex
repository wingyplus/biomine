defmodule Biomine do
  @moduledoc """
  Documentation for `Biomine`.
  """

  @doc """
  Format JavaScript/TypeScript source.
  """
  def format_js(source, opts \\ []) do
    # TODO: make opts support
    Biomine.Native.format_js(source)
  end
end
