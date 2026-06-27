defmodule Biomine.Native do
  @moduledoc false

  use Rustler, otp_app: :biomine, crate: :biomine_native

  def format_js(_source), do: :erlang.nif_error(:nif_not_loaded)
  def format_css(_source), do: :erlang.nif_error(:nif_not_loaded)
end
