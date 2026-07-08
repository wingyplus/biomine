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

  test "skips tags other than script and style" do
    assert TagFormatter.render_tag({"div", %{}, "hello"}, []) == :skip
  end

  test "formats the content of a style tag" do
    assert TagFormatter.render_tag({"style", %{}, "a{color:red}"}, []) ==
             {:ok, "a {\n  color: red;\n}"}
  end

  test "formats colocated css content" do
    attrs = %{":type" => "ColocatedCSS"}

    content = """
    .my-class{color:red}
    """

    assert {:ok, formatted} = TagFormatter.render_tag({"style", attrs, content}, [])
    assert formatted =~ ".my-class {\n  color: red;\n}"
  end

  test "passes Biomine CSS options from the formatter configuration" do
    assert TagFormatter.render_tag({"style", %{}, ~s(a{content:"hi"})},
             biomine: [css: [quote_style: :single]]
           ) ==
             {:ok, "a {\n  content: 'hi';\n}"}
  end

  test "skips style tag on parse errors" do
    assert TagFormatter.render_tag({"style", %{}, "a{"}, []) == :skip
  end

  test "skips style tag on invalid Biomine options" do
    assert TagFormatter.render_tag({"style", %{}, "a{color:red}"},
             biomine: [css: [quote_style: :invalid]]
           ) ==
             :skip
  end
end
