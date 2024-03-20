require "./spec_helper"

describe MartenTurbo::Handlers::RecordCreate do
  describe "#post" do
    it "redirects to the success route when a non-turbo request is handled and no turbo template is configured" do
      request = Marten::HTTP::Request.new(
        ::HTTP::Request.new(
          method: "POST",
          resource: "",
          headers: HTTP::Headers{
            "Accept"       => "text/html",
            "Host"         => "example.com",
            "Content-Type" => "application/x-www-form-urlencoded",
          },
          body: "name=newtag"
        )
      )
      handler = MartenTurbo::Handlers::RecordCreateSpec::TestWithoutTemplateHandler.new(request)

      response = handler.post

      response.should be_a Marten::HTTP::Response::Found
      response.as(Marten::HTTP::Response::Found).headers["Location"].should eq Marten.routes.reverse("dummy")
    end

    it "redirects to the success route when a non-turbo request is handled and a turbo template is configured" do
      request = Marten::HTTP::Request.new(
        ::HTTP::Request.new(
          method: "POST",
          resource: "",
          headers: HTTP::Headers{
            "Host"         => "example.com",
            "Content-Type" => "application/x-www-form-urlencoded",
            "Accept"       => "text/html",
          },
          body: "name=newtag"
        )
      )
      handler = MartenTurbo::Handlers::RecordCreateSpec::TestHandler.new(request)

      response = handler.post

      response.should be_a Marten::HTTP::Response::Found
      response.as(Marten::HTTP::Response::Found).headers["Location"].should eq Marten.routes.reverse("dummy")
    end

    it "redirects to the success route when a turbo request is handled but no turbo template is configured" do
      request = Marten::HTTP::Request.new(
        ::HTTP::Request.new(
          method: "POST",
          resource: "",
          headers: HTTP::Headers{
            "Host"         => "example.com",
            "Content-Type" => "application/x-www-form-urlencoded",
            "Accept"       => "text/vnd.turbo-stream.html",
          },
          body: "name=newtag"
        )
      )
      handler = MartenTurbo::Handlers::RecordCreateSpec::TestWithoutTemplateHandler.new(request)

      response = handler.post

      response.should be_a Marten::HTTP::Response::Found
      response.as(Marten::HTTP::Response::Found).headers["Location"].should eq Marten.routes.reverse("dummy")
    end

    it (
      "renders a turbo stream append action containing the newly created record if" \
      "a turbo request is handled and a turbo template is given"
    ) do
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
      handler = MartenTurbo::Handlers::RecordCreateSpec::TestHandler.new(request)

      response = handler.post

      response.should_not be_a Marten::HTTP::Response::Found
      response.content.strip.should contain "<turbo-stream action=\"append\" target=\"tags\">"
      response.content.strip.should contain "<div class=\"tag-name\">new-turbo-tag</div>"
      response.content.strip.should contain "</turbo-stream>"
    end

    it "renders a Turbo Stream append action containing no record when a wrong template variable is given" do
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
      handler = MartenTurbo::Handlers::RecordCreateSpec::TestWithInvalidRecordHandler.new(request)

      response = handler.post

      response.should_not be_a Marten::HTTP::Response::Found
      response.content.strip.should contain "<turbo-stream action=\"append\" target=\"tags\">"
      response.content.strip.should contain "<div class=\"tag-name\"></div>"
      response.content.strip.should contain "</turbo-stream>"
    end
  end
end

module MartenTurbo::Handlers::RecordCreateSpec
  class TestHandler < MartenTurbo::Handlers::RecordCreate
    model Tag
    schema TagCreateSchema
    success_route_name "dummy"
    template_name "tags/create.html"
    turbo_stream_name "tags/create.turbo_stream.html"
  end

  class TestWithInvalidRecordHandler < MartenTurbo::Handlers::RecordCreate
    model Tag
    schema TagCreateSchema
    success_route_name "dummy"
    template_name "tags/create.html"
    turbo_stream_name "tags/invalid_create.turbo_stream.html"
  end

  class TestWithoutTemplateHandler < MartenTurbo::Handlers::RecordCreate
    model Tag
    schema TagCreateSchema
    success_route_name "dummy"
    template_name "tags/create.html"
  end
end
