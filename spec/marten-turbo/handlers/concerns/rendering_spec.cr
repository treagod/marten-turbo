require "../spec_helper"

describe MartenTurbo::Handlers::Concerns::Rendering do
  describe "#render_turbo_stream?" do
    it "returns nil when neither a turbo stream nor a template name is configured" do
      handler = MartenTurbo::Handlers::Concerns::RenderingSpec::TestWithoutStreamHandler.new(
        MartenTurbo::Handlers::Concerns::RenderingSpec.turbo_request
      )

      handler.render_turbo_stream?.should be_nil
    end

    it "renders the configured template when no programmatic stream is returned" do
      handler = MartenTurbo::Handlers::Concerns::RenderingSpec::TestWithTemplateHandler.new(
        MartenTurbo::Handlers::Concerns::RenderingSpec.turbo_request
      )

      response = handler.render_turbo_stream?(context: {"record" => Tag.create!(name: "streamed")})

      response.not_nil!.content.strip.should contain "<div class=\"tag-name\">streamed</div>"
    end

    it "renders the programmatically generated stream" do
      handler = MartenTurbo::Handlers::Concerns::RenderingSpec::TestWithStreamHandler.new(
        MartenTurbo::Handlers::Concerns::RenderingSpec.turbo_request
      )

      response = handler.render_turbo_stream?

      response.not_nil!.content.strip.should contain "<div>Message</div>"
      response.not_nil!.content_type.should eq MartenTurbo::TURBO_CONTENT_TYPE
    end
  end
end

module MartenTurbo::Handlers::Concerns::RenderingSpec
  def self.turbo_request
    Marten::HTTP::Request.new(
      ::HTTP::Request.new(
        method: "GET",
        resource: "/",
        headers: HTTP::Headers{
          "Accept" => "text/vnd.turbo-stream.html",
          "Host"   => "example.com",
        }
      )
    )
  end

  class TestWithoutStreamHandler < Marten::Handlers::Base
    include MartenTurbo::Handlers::Concerns::Rendering
  end

  class TestWithTemplateHandler < Marten::Handlers::Base
    include MartenTurbo::Handlers::Concerns::Rendering

    turbo_stream_name "tags/create.turbo_stream.html"
  end

  class TestWithStreamHandler < Marten::Handlers::Base
    include MartenTurbo::Handlers::Concerns::Rendering

    def turbo_stream
      MartenTurbo::TurboStream.append("messages", "<div>Message</div>")
    end
  end
end
