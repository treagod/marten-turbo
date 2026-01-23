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

    it "accepts a block to create the turbo stream" do
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
      handler = MartenTurbo::Handlers::Concerns::StreamableSpec::TurboStreamYieldHandler.new(request)

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

  describe "request helpers" do
    it "knows when the current request expects a turbo response" do
      turbo_request = Marten::HTTP::Request.new(
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
      handler = MartenTurbo::Handlers::Concerns::StreamableSpec::TurboHelperHandler.new(turbo_request)
      handler.turbo_request_flag.should be_true

      regular_request = Marten::HTTP::Request.new(
        ::HTTP::Request.new(
          method: "POST",
          resource: "",
          headers: HTTP::Headers{
            "Host"         => "example.com",
            "Content-Type" => "application/x-www-form-urlencoded",
            "Accept"       => "text/html",
          },
          body: "name=new-turbo-tag"
        )
      )
      handler = MartenTurbo::Handlers::Concerns::StreamableSpec::TurboHelperHandler.new(regular_request)
      handler.turbo_request_flag.should be_false
    end

    it "knows when the current request is from a turbo native application" do
      native_request = Marten::HTTP::Request.new(
        ::HTTP::Request.new(
          method: "POST",
          resource: "",
          headers: HTTP::Headers{
            "Host"         => "example.com",
            "Content-Type" => "application/x-www-form-urlencoded",
            "Accept"       => "text/html",
            "User-Agent"   => "My Turbo Native App",
          },
          body: "name=new-turbo-tag"
        )
      )
      handler = MartenTurbo::Handlers::Concerns::StreamableSpec::TurboHelperHandler.new(native_request)
      handler.turbo_native_request_flag.should be_true
    end

    it "knows when the current request targets a turbo frame" do
      frame_request = Marten::HTTP::Request.new(
        ::HTTP::Request.new(
          method: "POST",
          resource: "",
          headers: HTTP::Headers{
            "Host"         => "example.com",
            "Content-Type" => "application/x-www-form-urlencoded",
            "Accept"       => "text/html",
            "Turbo-Frame"  => "modal",
          },
          body: "name=new-turbo-tag"
        )
      )
      handler = MartenTurbo::Handlers::Concerns::StreamableSpec::TurboHelperHandler.new(frame_request)
      handler.turbo_frame_request_flag.should be_true
      handler.turbo_frame_request_identifier.should eq "modal"
    end
  end
end

module MartenTurbo::Handlers::Concerns::StreamableSpec
  class TurboHelperHandler < Marten::Handler
    include MartenTurbo::Handlers::Concerns::Streamable

    def turbo_request_flag
      turbo_request?
    end

    def turbo_native_request_flag
      turbo_native_request?
    end

    def turbo_frame_request_flag
      turbo_frame_request?
    end

    def turbo_frame_request_identifier
      turbo_frame_request_id
    end
  end

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

  class TurboStreamYieldHandler < Marten::Handler
    include MartenTurbo::Handlers::Concerns::Streamable

    def post
      turbo_stream do
        remove("tag_1")
      end
    end
  end
end
