# Biomine

Elixir bindings for the [Biome](https://biomejs.dev/) formatter, exposed as a
Rust NIF. Format JavaScript/TypeScript (and, soon, CSS) source directly from
Elixir without shelling out to Node.

```elixir
iex> Biomine.format_js("const  x=1")
{:ok, "const x = 1;\n"}
```

## Installation

Add `biomine` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:biomine, "~> 0.1.0"}
  ]
end
```

The NIF ships as a **precompiled binary** via
[`rustler_precompiled`](https://hexdocs.pm/rustler_precompiled), so you do **not**
need a Rust toolchain to use this library — the matching artifact for your OS,
architecture, and NIF version is downloaded automatically at compile time.

## Mix formatter plugin

Biomine can be used as a `mix format` plugin for JavaScript and TypeScript
files. Add the plugin and the file extensions you want Mix to format to your
`.formatter.exs`:

```elixir
[
  plugins: [Biomine.Mix.JsFormatter],
  inputs: [
    "{mix,.formatter}.exs",
    "{config,lib,test}/**/*.{ex,exs}",
    "assets/**/*.{js,jsx,ts,tsx}"
  ]
]
```

Formatter options can be passed with the `:biomine` key:

```elixir
[
  plugins: [Biomine.Mix.JsFormatter],
  biomine: [
    quote_style: :single,
    semicolons: :as_needed
  ],
  inputs: [
    "{mix,.formatter}.exs",
    "{config,lib,test}/**/*.{ex,exs}",
    "assets/**/*.{js,jsx,ts,tsx}"
  ]
]
```

## Building from source

You only need this if you are hacking on the NIF, or you are on a target for
which no precompiled artifact is published.

Prerequisites: a [Rust toolchain](https://rustup.rs/) and Elixir/Erlang.

Set the `BIOMINE_BUILD` environment variable to force compilation from source
instead of downloading:

```sh
export BIOMINE_BUILD=1
mix deps.get
mix compile
```

Alternatively, force it from `config/config.exs`:

```elixir
config :rustler_precompiled, :force_build, biomine: true
```

Building from source requires `rustler` (already declared as an optional
dependency).

### Releasing precompiled binaries

Precompiled binaries are built by the
[`.github/workflows/release.yml`](.github/workflows/release.yml) workflow.

1. Bump `@version` in `mix.exs` and push a matching git tag (e.g. `v0.1.0`).
   CI builds each target and attaches the `.tar.gz` artifacts to the GitHub
   release.
2. Generate and commit the checksum file:

   ```sh
   mix rustler_precompiled.download Biomine.Native --all --print
   ```

   This produces `checksum-Elixir.Biomine.Native.exs`, which must be committed
   and included in the Hex package.
3. Publish to Hex with `mix hex.publish`.

## Documentation

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can be
found at <https://hexdocs.pm/biomine>.
