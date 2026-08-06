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

    it "renders a turbo stream error when the schema validation fails for a turbo request" do
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
          body: "name="
        )
      )
      handler = MartenTurbo::Handlers::RecordUpdateSpec::TestHandler.new(request, params)

      response = handler.post

      response.should_not be_a Marten::HTTP::Response::Found
      response.status.should eq 422
      response.content.strip.should contain "<div id=\"tag-update-errors\">"
    end

    it "respects custom #prepare_record_attributes implementations" do
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
      handler = MartenTurbo::Handlers::RecordUpdateSpec::TestWithPreparedAttributesHandler.new(request, params)

      response = handler.post

      tag.reload.name.should eq "prepared-updatedtag"
      response.content.strip.should contain "<div>prepared-updatedtag</div>"
    end

    it "calls custom #save_record implementations" do
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
      handler = MartenTurbo::Handlers::RecordUpdateSpec::TestWithCustomSaveHandler.new(request, params)

      response = handler.post

      response.should be_a Marten::HTTP::Response::Found
      handler.save_record_called?.should be_true
      tag.reload.name.should eq "saved-updatedtag"
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
    turbo_invalid_stream_name "tags/update_errors.turbo_stream.html"
  end

  class TestWithoutTemplateHandler < MartenTurbo::Handlers::RecordUpdate
    model Tag
    schema TagCreateSchema
    success_route_name "dummy"
    template_name "tags/update.html"
  end

  class TestWithPreparedAttributesHandler < MartenTurbo::Handlers::RecordUpdate
    model Tag
    schema TagCreateSchema
    success_route_name "dummy"
    template_name "tags/update.html"
    turbo_stream_name "tags/update.turbo_stream.html"

    def prepare_record_attributes
      attributes = super
      attributes["name"] = "prepared-#{attributes["name"]}"
      attributes
    end
  end

  class TestWithCustomSaveHandler < MartenTurbo::Handlers::RecordUpdate
    model Tag
    schema TagCreateSchema
    success_route_name "dummy"
    template_name "tags/update.html"

    getter? save_record_called : Bool = false

    def save_record : Nil
      @save_record_called = true

      record.update!(name: "saved-#{schema.validated_data["name"]}")
    end
  end
end
