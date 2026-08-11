require "../../spec_helper"

describe MartenTurbo::Template::Tag::TurboStream do
  describe "::new" do
    it "raises if turbo_stream does not define an action" do
      parser = Marten::Template::Parser.new("")

      expect_raises(
        Marten::Template::Errors::InvalidSyntax,
        "Malformed turbo_stream tag: you must define an action"
      ) do
        MartenTurbo::Template::Tag::TurboStream.new(parser, "turbo_stream")
      end
    end

    it "raises if turbo_stream does not define a target_id" do
      parser = Marten::Template::Parser.new("{% turbo_stream 'append' %}")

      expect_raises(
        Marten::Template::Errors::InvalidSyntax,
        "Malformed turbo_stream tag: you must define an action and a target id"
      ) do
        MartenTurbo::Template::Tag::TurboStream.new(parser, "turbo_stream 'append'")
      end
    end

    it "raises if turbo_stream block is not closed when 'do' is present at the end" do
      parser = Marten::Template::Parser.new(
        <<-TEMPLATE
          <p>some content</p>
          TEMPLATE
      )

      expect_raises(
        Marten::Template::Errors::InvalidSyntax,
        "Unclosed tags, expected: end_turbo_stream"
      ) do
        MartenTurbo::Template::Tag::TurboStream.new(parser, "turbo_stream 'append' 'tags' do")
      end
    end
  end

  describe "#render" do
    it "properly renders a turbo-stream tag with the correct action and target" do
      parser = Marten::Template::Parser.new("")
      tag = MartenTurbo::Template::Tag::TurboStream.new(parser, "turbo_stream 'remove' 'my-id'")

      content = tag.render(Marten::Template::Context.new)
      content.should contain "<turbo-stream action=\"remove\" target=\"my-id\">"
      content.should_not contain "<template>"
    end

    it "properly renders a turbo-stream tag with the correct action and target when given a Marten::Model" do
      tag_model = Tag.create!(name: "Marten Turbo")

      parser = Marten::Template::Parser.new("")
      tag = MartenTurbo::Template::Tag::TurboStream.new(parser, "turbo_stream 'remove' tag")

      context = Marten::Template::Context{"tag" => tag_model}

      tag.render(context).should contain "<turbo-stream action=\"remove\" target=\"tag_#{tag_model.pk!}\">"
    end

    it "properly renders a turbo-stream tag using selector targeting for dot-prefixed string targets" do
      parser = Marten::Template::Parser.new("")
      tag = MartenTurbo::Template::Tag::TurboStream.new(
        parser,
        "turbo_stream 'remove' '.event_1'"
      )

      content = tag.render(Marten::Template::Context.new)
      content.should contain "<turbo-stream action=\"remove\" targets=\".event_1\">"
      content.should_not contain "<turbo-stream action=\"remove\" target=\".event_1\">"
    end

    it "properly renders a turbo-stream tag using selector targeting for dot-prefixed symbol targets" do
      parser = Marten::Template::Parser.new("")
      tag = MartenTurbo::Template::Tag::TurboStream.new(parser, "turbo_stream 'remove' selector")

      context = Marten::Template::Context{"selector" => :".event_2"}

      content = tag.render(context)
      content.should contain "<turbo-stream action=\"remove\" targets=\".event_2\">"
      content.should_not contain "<turbo-stream action=\"remove\" target=\".event_2\">"
    end

    it "properly renders a turbo-stream tag with correct specified template" do
      tag_model = Tag.create!(name: "Marten Turbo")

      parser = Marten::Template::Parser.new("")
      tag = MartenTurbo::Template::Tag::TurboStream.new(
        parser,
        "turbo_stream 'append' 'tags' template: 'tags/tag.html'"
      )

      context = Marten::Template::Context{"tag" => tag_model}

      content = tag.render(context)
      content.should contain %(<turbo-stream action="append" target="tags">)
      content.should contain "<div class=\"tag_#{tag_model.pk}\">"
      content.should contain "Marten Turbo"
    end

    it "raises if the specified template could not be found" do
      tag_model = Tag.create!(name: "Marten Turbo")

      parser = Marten::Template::Parser.new("")
      tag = MartenTurbo::Template::Tag::TurboStream.new(
        parser,
        "turbo_stream 'append' 'tags' template: 'tags/not_existing_tag.html'"
      )

      context = Marten::Template::Context{"tag" => tag_model}

      expect_raises(
        Marten::Template::Errors::TemplateNotFound,
        "Template tags/not_existing_tag.html could not be found"
      ) do
        tag.render(context)
      end
    end

    it "raises if the specified template value is not a string" do
      tag_model = Tag.create!(name: "Marten Turbo")

      parser = Marten::Template::Parser.new("")
      tag = MartenTurbo::Template::Tag::TurboStream.new(parser, "turbo_stream 'append' 'tags' template: 1")

      context = Marten::Template::Context{"tag" => tag_model}

      expect_raises(
        Marten::Template::Errors::UnsupportedValue,
        "Template name must resolve to a string, git a Int32 instead."
      ) do
        tag.render(context)
      end
    end

    it "properly renders a turbo_stream block if 'do' is present as last argument" do
      parser = Marten::Template::Parser.new(
        <<-TEMPLATE
          <p>some content</p>
          {% end_turbo_stream %}
          TEMPLATE
      )
      tag = MartenTurbo::Template::Tag::TurboStream.new(parser, "turbo_stream.append 'tags' do")

      tag.render(Marten::Template::Context.new).should contain "<p>some content</p>"
    end

    it "properly renders a turbo_stream block targeting a Marten::Model" do
      tag_model = Tag.create!(name: "Marten Turbo")

      parser = Marten::Template::Parser.new(
        <<-TEMPLATE
          <div>Updated article</div>
          {% end_turbo_stream %}
          TEMPLATE
      )
      tag = MartenTurbo::Template::Tag::TurboStream.new(parser, "turbo_stream 'replace' tag do")

      context = Marten::Template::Context{"tag" => tag_model}

      content = tag.render(context)

      content.should contain %(<turbo-stream action="replace" target="tag_#{tag_model.pk}">)
      content.should contain "<div>Updated article</div>"
    end

    it "escapes a resolved target instead of introducing additional attributes" do
      parser = Marten::Template::Parser.new("")
      tag = MartenTurbo::Template::Tag::TurboStream.new(parser, "turbo_stream 'append' target")

      context = Marten::Template::Context{"target" => %(tags" data-invalid="true)}

      content = tag.render(context)

      content.should contain %(target="tags&quot; data-invalid=&quot;true")
      content.should_not contain %(data-invalid="true")
    end

    it "escapes a resolved target exactly once" do
      parser = Marten::Template::Parser.new("")
      tag = MartenTurbo::Template::Tag::TurboStream.new(parser, "turbo_stream 'append' target")

      context = Marten::Template::Context{"target" => "tags&others"}

      content = tag.render(context)

      content.should contain %(target="tags&amp;others")
      content.should_not contain "&amp;amp;"
    end

    it "leaves non-ASCII characters in a resolved target untouched" do
      parser = Marten::Template::Parser.new("")
      tag = MartenTurbo::Template::Tag::TurboStream.new(parser, "turbo_stream 'append' target")

      context = Marten::Template::Context{"target" => "tâche_日本語"}

      tag.render(context).should contain %(target="tâche_日本語")
    end

    it "does not escape the rendered stream content" do
      parser = Marten::Template::Parser.new(
        <<-TEMPLATE
          <div class="tag">Ben & Jerry's</div>
          {% end_turbo_stream %}
          TEMPLATE
      )
      tag = MartenTurbo::Template::Tag::TurboStream.new(parser, "turbo_stream 'append' 'tags' do")

      tag.render(Marten::Template::Context.new).should contain %(<div class="tag">Ben & Jerry's</div>)
    end
  end
end
