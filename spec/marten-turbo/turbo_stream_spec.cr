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
  end
end
