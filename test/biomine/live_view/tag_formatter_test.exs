defmodule Biomine.LiveView.TagFormatterTest do
  use ExUnit.Case, async: true

  alias Biomine.LiveView.TagFormatter

  test "formats the content of a script tag" do
    assert TagFormatter.render_tag({"script", %{}, "let x=1"}, []) == {:ok, "let x = 1;"}
  end

  test "formats colocated hook content" do
    attrs = %{":type" => "ColocatedHook", "name" => ".MyHook"}

    content = """
    export default {
      mounted() {
      console.log('mounted')
      }
    }
    """

    assert {:ok, formatted} = TagFormatter.render_tag({"script", attrs, content}, [])
    assert formatted =~ "console.log(\"mounted\");"
  end

  test "passes Biomine options from the formatter configuration" do
    assert TagFormatter.render_tag({"script", %{}, "let x='hello'"},
             biomine: [js: [quote_style: :single]]
           ) ==
             {:ok, "let x = 'hello';"}
  end

  test "skips on parse errors" do
    assert TagFormatter.render_tag({"script", %{}, "funtion f("}, []) == :skip
  end

  test "skips on invalid Biomine options" do
    assert TagFormatter.render_tag({"script", %{}, "let x=1"},
             biomine: [js: [quote_style: :invalid]]
           ) ==
             :skip
  end

  test "skips tags other than script" do
    assert TagFormatter.render_tag({"style", %{}, "a{color:red}"}, []) == :skip
  end
end
