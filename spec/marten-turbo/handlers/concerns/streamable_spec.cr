# spec/marten_turbo/handlers/concerns/streamable_spec.cr
require "../spec_helper"

describe MartenTurbo::Handlers::Concerns::Streamable do
  describe "#turbo_stream" do
    it "can render a template" do
      request = Marten::HTTP::Request.new(
        ::HTTP::Request.new(
          method: "POST",
          resource: "",
          headers: HTTP::Headers{
            "Host"         => "example.com",
            "Content-Type" => "application/x-www-form-urlencoded",
            "Accept"       => "text/vnd.turbo-stream.html",
          },
          body: "name=new-turbo-tag"
        )
      )
      handler = MartenTurbo::Handlers::Concerns::StreamableSpec::TurboTemplateHandler.new(request)

      response = handler.post

      response.content_type.should eq "text/vnd.turbo-stream.html"
      response.content.strip.should contain %(<turbo-stream action="append" target="tags">)
    end

    it "can render a MartenTurbo::TurboStream" do
      request = Marten::HTTP::Request.new(
        ::HTTP::Request.new(
          method: "POST",
          resource: "",
          headers: HTTP::Headers{
            "Host"         => "example.com",
            "Content-Type" => "application/x-www-form-urlencoded",
            "Accept"       => "text/vnd.turbo-stream.html",
          },
          body: "name=new-turbo-tag"
        )
      )
      handler = MartenTurbo::Handlers::Concerns::StreamableSpec::TurboStreamHandler.new(request)

      response = handler.post

      response.content_type.should eq "text/vnd.turbo-stream.html"
      response.content.strip.should contain %(<turbo-stream action="remove" target="tag_1">)
    end

    it "can set a custom status" do
      request = Marten::HTTP::Request.new(
        ::HTTP::Request.new(
          method: "POST",
          resource: "",
          headers: HTTP::Headers{
            "Host"         => "example.com",
            "Content-Type" => "application/x-www-form-urlencoded",
            "Accept"       => "text/vnd.turbo-stream.html",
          },
          body: "name=new-turbo-tag"
        )
      )
      handler = MartenTurbo::Handlers::Concerns::StreamableSpec::TurboStreamStatusCodeHandler.new(request)

      response = handler.post

      response.content_type.should eq "text/vnd.turbo-stream.html"
      response.content.strip.should contain %(<turbo-stream action="remove" target="tag_1">)
      response.status.should eq 418
    end
  end
end

module MartenTurbo::Handlers::Concerns::StreamableSpec
  class TurboTemplateHandler < Marten::Handler
    include MartenTurbo::Handlers::Concerns::Streamable

    def post
      turbo_stream("tags/create.turbo_stream.html")
    end
  end

  class TurboStreamHandler < Marten::Handler
    include MartenTurbo::Handlers::Concerns::Streamable

    def post
      turbo_stream(TurboStream.remove("tag_1"))
    end
  end

  class TurboStreamStatusCodeHandler < Marten::Handler
    include MartenTurbo::Handlers::Concerns::Streamable

    def post
      turbo_stream(TurboStream.remove("tag_1"), 418)
    end
  end
end
