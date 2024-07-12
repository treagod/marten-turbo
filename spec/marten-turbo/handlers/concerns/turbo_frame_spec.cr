require "../spec_helper"

describe MartenTurbo::Handlers::TurboFrame do
  describe "#turbo_frame_request?" do
    it "returns false when the 'Turbo-Frame' header is not present" do
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
      handler = MartenTurbo::Handlers::TurboFrameSpec::TestHandler.new(request)

      handler.turbo_frame_request?.should eq false
    end

    it "returns true when the 'Turbo-Frame' header is present" do
      request = Marten::HTTP::Request.new(
        ::HTTP::Request.new(
          method: "POST",
          resource: "",
          headers: HTTP::Headers{
            "Host"         => "example.com",
            "Content-Type" => "application/x-www-form-urlencoded",
            "Accept"       => "text/vnd.turbo-stream.html",
            "Turbo-Frame"  => "new_message",
          },
          body: "name=new-turbo-tag"
        )
      )
      handler = MartenTurbo::Handlers::TurboFrameSpec::TestHandler.new(request)

      handler.turbo_frame_request?.should eq true
    end
  end

  describe "#turbo_frame_request_id" do
    it "returns nil when the 'Turbo-Frame' header is not present" do
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
      handler = MartenTurbo::Handlers::TurboFrameSpec::TestHandler.new(request)

      handler.turbo_frame_request_id.should eq nil
    end

    it "returns the value of the 'Turbo-Frame' header when it is present" do
      request = Marten::HTTP::Request.new(
        ::HTTP::Request.new(
          method: "POST",
          resource: "",
          headers: HTTP::Headers{
            "Host"         => "example.com",
            "Content-Type" => "application/x-www-form-urlencoded",
            "Accept"       => "text/vnd.turbo-stream.html",
            "Turbo-Frame"  => "new_message",
          },
          body: "name=new-turbo-tag"
        )
      )
      handler = MartenTurbo::Handlers::TurboFrameSpec::TestHandler.new(request)

      handler.turbo_frame_request_id.should eq "new_message"
    end
  end
end

module MartenTurbo::Handlers::TurboFrameSpec
  class TestHandler < MartenTurbo::Handlers::RecordCreate
    include MartenTurbo::Handlers::TurboFrame

    model Tag
    schema TagCreateSchema
    success_route_name "dummy"
    template_name "tags/create.html"
    turbo_stream_name "tags/create.turbo_stream.html"
  end
end
