require "./spec_helper"

describe MartenTurbo::Handlers::RecordUpdate do
  describe "#post" do
    it (
      "updates an existing record and returns the expected redirect when no turbo request " \
      "was made and no template is given"
    ) do
      tag = Tag.create(name: "oldtag")

      params = Marten::Routing::MatchParameters{"pk" => tag.id!}
      request = Marten::HTTP::Request.new(
        ::HTTP::Request.new(
          method: "POST",
          resource: "",
          headers: HTTP::Headers{
            "Accept"       => "text/html",
            "Host"         => "example.com",
            "Content-Type" => "application/x-www-form-urlencoded",
          },
          body: "name=updatedtag"
        )
      )
      handler = MartenTurbo::Handlers::RecordUpdateSpec::TestHandler.new(request, params)

      response = handler.post

      response.should be_a Marten::HTTP::Response::Found
      response.as(Marten::HTTP::Response::Found).headers["Location"].should eq Marten.routes.reverse("dummy")
      tag.reload.name.should eq "updatedtag"
    end

    it (
      "updates an existing record and returns the expected redirect when no turbo request " \
      "was made and a template is given"
    ) do
      tag = Tag.create(name: "oldtag")

      params = Marten::Routing::MatchParameters{"pk" => tag.id!}
      request = Marten::HTTP::Request.new(
        ::HTTP::Request.new(
          method: "POST",
          resource: "",
          headers: HTTP::Headers{
            "Accept"       => "text/html",
            "Host"         => "example.com",
            "Content-Type" => "application/x-www-form-urlencoded",
          },
          body: "name=updatedtag"
        )
      )
      handler = MartenTurbo::Handlers::RecordUpdateSpec::TestWithoutTemplateHandler.new(request, params)

      response = handler.post

      response.should be_a Marten::HTTP::Response::Found
      response.as(Marten::HTTP::Response::Found).headers["Location"].should eq Marten.routes.reverse("dummy")
      tag.reload.name.should eq "updatedtag"
    end

    it (
      "updates an existing record and returns the expected redirect when a turbo request " \
      "was made and no template is given"
    ) do
      tag = Tag.create(name: "oldtag")

      params = Marten::Routing::MatchParameters{"pk" => tag.id!}
      request = Marten::HTTP::Request.new(
        ::HTTP::Request.new(
          method: "POST",
          resource: "",
          headers: HTTP::Headers{
            "Accept"       => "text/vnd.turbo-stream.html",
            "Host"         => "example.com",
            "Content-Type" => "application/x-www-form-urlencoded",
          },
          body: "name=updatedtag"
        )
      )
      handler = MartenTurbo::Handlers::RecordUpdateSpec::TestWithoutTemplateHandler.new(request, params)

      response = handler.post

      response.should be_a Marten::HTTP::Response::Found
      response.as(Marten::HTTP::Response::Found).headers["Location"].should eq Marten.routes.reverse("dummy")
      tag.reload.name.should eq "updatedtag"
    end

    it (
      "updates an existing record and returns a update turbo stream " \
      "when a turbo request was made and a template is given"
    ) do
      tag = Tag.create(name: "oldtag")

      params = Marten::Routing::MatchParameters{"pk" => tag.id!}
      request = Marten::HTTP::Request.new(
        ::HTTP::Request.new(
          method: "POST",
          resource: "",
          headers: HTTP::Headers{
            "Accept"       => "text/vnd.turbo-stream.html",
            "Host"         => "example.com",
            "Content-Type" => "application/x-www-form-urlencoded",
          },
          body: "name=updatedtag"
        )
      )
      handler = MartenTurbo::Handlers::RecordUpdateSpec::TestHandler.new(request, params)

      response = handler.post

      response.should_not be_a Marten::HTTP::Response::Found
      response.content.strip.should contain "<turbo-stream action=\"replace\" target=\"tag_#{tag.pk}\">"
      response.content.strip.should contain "<div>updatedtag</div>"
      response.content.strip.should contain "</turbo-stream>"
    end
  end
end

module MartenTurbo::Handlers::RecordUpdateSpec
  class TestHandler < MartenTurbo::Handlers::RecordUpdate
    model Tag
    schema TagCreateSchema
    success_route_name "dummy"
    template_name "tags/update.html"
    turbo_stream_name "tags/update.turbo_stream.html"
  end

  class TestWithoutTemplateHandler < MartenTurbo::Handlers::RecordUpdate
    model Tag
    schema TagCreateSchema
    success_route_name "dummy"
    template_name "tags/update.html"
  end
end
