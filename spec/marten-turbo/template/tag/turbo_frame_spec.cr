require "../../spec_helper"

describe MartenTurbo::Template::Tag::TurboFrame do
  describe "::new" do
    it "raises if the turbo_frame tag does not define an identifier" do
      parser = Marten::Template::Parser.new(
        "<p>Test</p>{% end_turbo_frame %}"
      )

      expect_raises(
        Marten::Template::Errors::InvalidSyntax,
        "Malformed turbo_frame tag: you must define an identifier"
      ) do
        MartenTurbo::Template::Tag::TurboFrame.new(parser, "turbo_frame")
      end
    end
  end

  describe "#render" do
    it "properly renders a turbo-frame tag with the correct identifier and body" do
      parser = Marten::Template::Parser.new("<p>Test</p>{% end_turbo_frame %}")
      tag = MartenTurbo::Template::Tag::TurboFrame.new(parser, "turbo_frame 'tasks'")

      tag.render(Marten::Template::Context.new).should contain %(<turbo-frame id="tasks">)
    end

    it "properly renders a turbo-frame tag with additional attributes" do
      parser = Marten::Template::Parser.new("<p>Test</p>{% end_turbo_frame %}")
      tag = MartenTurbo::Template::Tag::TurboFrame.new(
        parser,
        "turbo_frame 'tasks' src: 'some/path', loading: 'lazy'"
      )

      content = tag.render(Marten::Template::Context.new)

      content.should contain %(<turbo-frame id="tasks" src="some/path" loading="lazy">)
    end

    it "properly renders a turbo-frame tag with a dynamic identifier when given a Marten::Model" do
      tag_model = Tag.create!(name: "Marten Turbo")

      parser = Marten::Template::Parser.new("<p>Test</p>{% end_turbo_frame %}")
      template_tag = MartenTurbo::Template::Tag::TurboFrame.new(
        parser,
        "turbo_frame tag src: 'some/path', loading: 'lazy'"
      )

      context = Marten::Template::Context{"tag" => tag_model}

      content = template_tag.render(context)

      content.should contain %(<turbo-frame id="tag_#{tag_model.pk!}" src="some/path" loading="lazy">)
    end

    it "properly returns the body content within the turbo-frame tag" do
      parser = Marten::Template::Parser.new("<div>Body Content</div>{% end_turbo_frame %}")
      tag = MartenTurbo::Template::Tag::TurboFrame.new(parser, "turbo_frame 'body_test'")

      content = tag.render(Marten::Template::Context.new)

      content.should contain "<div>Body Content</div>"
    end
  end
end
