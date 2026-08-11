require "./spec_helper"

describe MartenTurbo::TurboStream do
  describe "::new" do
    it "initializes with an empty streams array" do
      stream = MartenTurbo::TurboStream.new
      stream.to_s.should eq ""
    end

    it "accepts a block to initialize the stream" do
      stream = MartenTurbo::TurboStream.new do
        append("messages", "<div>Message 1</div>")
      end

      stream.to_s.should contain "<turbo-stream action=\"append\" target=\"messages\">"
      stream.to_s.should contain "<div>Message 1</div>"
      stream.to_s.should contain "</turbo-stream>"
    end

    it "accepts a block defining multiple actions" do
      stream = MartenTurbo::TurboStream.new do
        append("articles", "<div>New Article</div>")
        replace("article_form", "<form></form>")
      end

      content = stream.to_s

      content.should contain %(<turbo-stream action="append" target="articles">)
      content.should contain "<div>New Article</div>"
      content.should contain %(<turbo-stream action="replace" target="article_form">)
      content.should contain "<form></form>"
    end
  end

  describe "#append" do
    it "adds an append action to the streams" do
      stream = MartenTurbo::TurboStream.new
      stream.append("messages", "<div>Message 1</div>")
      stream.to_s.should contain "<turbo-stream action=\"append\" target=\"messages\">"
      stream.to_s.should contain "<div>Message 1</div>"
      stream.to_s.should contain "</turbo-stream>"
    end
  end

  describe "#prepend" do
    it "adds a prepend action to the streams" do
      stream = MartenTurbo::TurboStream.new
      stream.prepend("messages", "<div>Message 2</div>")

      stream.to_s.should contain "<turbo-stream action=\"prepend\" target=\"messages\">"
      stream.to_s.should contain "<div>Message 2</div>"
      stream.to_s.should contain "</turbo-stream>"
    end
  end

  describe "#replace" do
    it "adds a replace action to the streams" do
      stream = MartenTurbo::TurboStream.new
      stream.replace("message_1", "<div>Updated Message 1</div>")

      stream.to_s.should contain "<turbo-stream action=\"replace\" target=\"message_1\">"
      stream.to_s.should contain "<div>Updated Message 1</div>"
      stream.to_s.should contain "</turbo-stream>"
    end

    it "uses targets for dot-prefixed string targets" do
      stream = MartenTurbo::TurboStream.new
      stream.replace(".message", "<div>Updated Message</div>")

      stream.to_s.should contain "<turbo-stream action=\"replace\" targets=\".message\">"
      stream.to_s.should_not contain "<turbo-stream action=\"replace\" target=\".message\">"
      stream.to_s.should contain "<div>Updated Message</div>"
      stream.to_s.should contain "</turbo-stream>"
    end

    it "uses targets for dot-prefixed symbol targets" do
      stream = MartenTurbo::TurboStream.new
      stream.replace(:".message", "<div>Updated Message</div>")

      stream.to_s.should contain "<turbo-stream action=\"replace\" targets=\".message\">"
      stream.to_s.should_not contain "<turbo-stream action=\"replace\" target=\".message\">"
      stream.to_s.should contain "<div>Updated Message</div>"
      stream.to_s.should contain "</turbo-stream>"
    end
  end

  describe "#remove" do
    it "adds a remove action to the streams" do
      stream = MartenTurbo::TurboStream.new
      stream.remove("message_2")

      stream.to_s.should contain "<turbo-stream action=\"remove\" target=\"message_2\">"
      stream.to_s.should_not contain "<template>"
      stream.to_s.should contain "</turbo-stream>"
    end

    it "adds a remove action to the streams using a record" do
      tag = Tag.create!(name: "Tag 1")
      stream = MartenTurbo::TurboStream.new
      stream.remove(tag)

      stream.to_s.should contain "<turbo-stream action=\"remove\" target=\"tag_#{tag.pk!}\">"
      stream.to_s.should_not contain "<template>"
      stream.to_s.should contain "</turbo-stream>"
    end

    it "uses targets for dot-prefixed string targets" do
      stream = MartenTurbo::TurboStream.new
      stream.remove(".message_2")

      stream.to_s.should contain "<turbo-stream action=\"remove\" targets=\".message_2\">"
      stream.to_s.should_not contain "<turbo-stream action=\"remove\" target=\".message_2\">"
      stream.to_s.should_not contain "<template>"
      stream.to_s.should contain "</turbo-stream>"
    end

    it "uses targets for dot-prefixed symbol targets" do
      stream = MartenTurbo::TurboStream.new
      stream.remove(:".message_2")

      stream.to_s.should contain "<turbo-stream action=\"remove\" targets=\".message_2\">"
      stream.to_s.should_not contain "<turbo-stream action=\"remove\" target=\".message_2\">"
      stream.to_s.should_not contain "<template>"
      stream.to_s.should contain "</turbo-stream>"
    end

    it "keeps target for non-dot symbol targets" do
      stream = MartenTurbo::TurboStream.new
      stream.remove(:message_2)

      stream.to_s.should contain "<turbo-stream action=\"remove\" target=\"message_2\">"
      stream.to_s.should_not contain "<turbo-stream action=\"remove\" targets=\"message_2\">"
      stream.to_s.should_not contain "<template>"
      stream.to_s.should contain "</turbo-stream>"
    end
  end

  describe "Class methods" do
    it "::append returns a new TurboStream with the append action" do
      stream = MartenTurbo::TurboStream.append("messages", "<div>Message 3</div>")

      stream.to_s.should contain "<turbo-stream action=\"append\" target=\"messages\">"
      stream.to_s.should contain "<div>Message 3</div>"
      stream.to_s.should contain "</turbo-stream>"
    end

    it "::remove returns a new TurboStream with the remove action" do
      stream = MartenTurbo::TurboStream.remove("message_2")

      stream.to_s.should contain "<turbo-stream action=\"remove\" target=\"message_2\">"
      stream.to_s.should_not contain "<template>"
      stream.to_s.should contain "</turbo-stream>"
    end

    it "::remove accepts a model returns a new TurboStream with the remove action" do
      tag = Tag.create!(name: "Tag 1")
      stream = MartenTurbo::TurboStream.remove(tag)

      stream.to_s.should contain "<turbo-stream action=\"remove\" target=\"tag_#{tag.pk!}\">"
      stream.to_s.should_not contain "<template>"
      stream.to_s.should contain "</turbo-stream>"
    end

    it "::remove uses targets for dot-prefixed string targets" do
      stream = MartenTurbo::TurboStream.remove(".message_2")

      stream.to_s.should contain "<turbo-stream action=\"remove\" targets=\".message_2\">"
      stream.to_s.should_not contain "<turbo-stream action=\"remove\" target=\".message_2\">"
      stream.to_s.should_not contain "<template>"
      stream.to_s.should contain "</turbo-stream>"
    end

    it "::remove uses targets for dot-prefixed symbol targets" do
      stream = MartenTurbo::TurboStream.remove(:".message_2")

      stream.to_s.should contain "<turbo-stream action=\"remove\" targets=\".message_2\">"
      stream.to_s.should_not contain "<turbo-stream action=\"remove\" target=\".message_2\">"
      stream.to_s.should_not contain "<template>"
      stream.to_s.should contain "</turbo-stream>"
    end

    it "::remove keeps target for non-dot symbol targets" do
      stream = MartenTurbo::TurboStream.remove(:message_2)

      stream.to_s.should contain "<turbo-stream action=\"remove\" target=\"message_2\">"
      stream.to_s.should_not contain "<turbo-stream action=\"remove\" targets=\"message_2\">"
      stream.to_s.should_not contain "<template>"
      stream.to_s.should contain "</turbo-stream>"
    end
  end

  describe "attribute escaping" do
    it "escapes double quotes in targets instead of introducing additional attributes" do
      stream = MartenTurbo::TurboStream.remove(%(item" data-invalid="true))

      stream.to_s.should contain %(target="item&quot; data-invalid=&quot;true")
      stream.to_s.should_not contain %(data-invalid="true")
    end

    it "escapes single quotes in targets" do
      stream = MartenTurbo::TurboStream.remove("item's")

      stream.to_s.should contain %(target="item&#39;s")
    end

    it "escapes ampersands in targets" do
      stream = MartenTurbo::TurboStream.remove("item&other")

      stream.to_s.should contain %(target="item&amp;other")
    end

    it "escapes less-than and greater-than characters in targets" do
      stream = MartenTurbo::TurboStream.remove("<script>")

      stream.to_s.should contain %(target="&lt;script&gt;")
      stream.to_s.should_not contain "<script>"
    end

    it "leaves non-ASCII characters in targets untouched" do
      stream = MartenTurbo::TurboStream.remove("tâche_日本語")

      stream.to_s.should contain %(target="tâche_日本語")
    end

    it "escapes the action name" do
      stream = MartenTurbo::TurboStream.action(%(append" hidden="true), "messages", nil)

      stream.to_s.should contain %(action="append&quot; hidden=&quot;true")
      stream.to_s.should_not contain %(hidden="true")
    end

    it "escapes attribute values exactly once" do
      stream = MartenTurbo::TurboStream.remove("item&other")

      stream.to_s.should_not contain "&amp;amp;"
    end

    it "does not escape the rendered stream content" do
      stream = MartenTurbo::TurboStream.append("messages", %(<div class="tag">Ben & Jerry's</div>))

      stream.to_s.should contain %(<div class="tag">Ben & Jerry's</div>)
    end
  end
end
