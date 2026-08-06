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

    it (
      "renders a turbo stream append action containing the newly created record if" \
      "a turbo request is handled and a custom turbo render is defined"
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
      handler = MartenTurbo::Handlers::RecordCreateSpec::TestWithCustomRenderMethod.new(request)

      response = handler.post

      response.should_not be_a Marten::HTTP::Response::Found
      response.content.strip.should contain "<turbo-stream action=\"append\" target=\"messages\">"
      response.content.strip.should contain "<div>New Message</div>"
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

    it "renders a turbo stream error when the schema validation fails for a turbo request" do
      request = Marten::HTTP::Request.new(
        ::HTTP::Request.new(
          method: "POST",
          resource: "",
          headers: HTTP::Headers{
            "Host"         => "example.com",
            "Content-Type" => "application/x-www-form-urlencoded",
            "Accept"       => "text/vnd.turbo-stream.html",
          },
          body: ""
        )
      )
      handler = MartenTurbo::Handlers::RecordCreateSpec::TestHandler.new(request)

      response = handler.post

      response.should_not be_a Marten::HTTP::Response::Found
      response.status.should eq 422
      response.content.strip.should contain "<div id=\"tag-form-errors\">"
    end

    it "evaluates #turbo_stream exactly once when a programmatic turbo stream is returned" do
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
      handler = MartenTurbo::Handlers::RecordCreateSpec::TestWithCountedTurboStreamHandler.new(request)

      response = handler.post

      response.content.strip.should contain "<div>New Message</div>"
      handler.turbo_stream_calls.should eq 1
    end

    it "does not evaluate #turbo_stream when a regular request falls back to its regular response" do
      request = Marten::HTTP::Request.new(
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
      handler = MartenTurbo::Handlers::RecordCreateSpec::TestWithCountedTurboStreamHandler.new(request)

      response = handler.post

      response.should be_a Marten::HTTP::Response::Found
      handler.turbo_stream_calls.should eq 0
    end

    it "evaluates #turbo_stream once and gives it precedence when a turbo stream template is also configured" do
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
      handler = MartenTurbo::Handlers::RecordCreateSpec::TestWithCountedTurboStreamAndTemplateHandler.new(request)

      response = handler.post

      response.content.strip.should contain "<div>New Message</div>"
      response.content.strip.should_not contain "<div class=\"tag-name\">"
      handler.turbo_stream_calls.should eq 1
    end

    it "does not require a success route when a turbo stream response is configured" do
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
      handler = MartenTurbo::Handlers::RecordCreateSpec::TestWithoutSuccessRouteHandler.new(request)

      response = handler.post

      response.content.strip.should contain "<div class=\"tag-name\">new-turbo-tag</div>"
      handler.record.not_nil!.persisted?.should be_true
    end

    it "exposes the created record through #record" do
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

      handler.post

      handler.record.should be_a Tag
      handler.record.not_nil!.name.should eq "newtag"
      handler.record.not_nil!.persisted?.should be_true
    end

    it "respects custom #prepare_record_attributes implementations for regular requests" do
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
      handler = MartenTurbo::Handlers::RecordCreateSpec::TestWithPreparedAttributesHandler.new(request)

      response = handler.post

      response.should be_a Marten::HTTP::Response::Found
      handler.record.not_nil!.name.should eq "prepared-newtag"
    end

    it "respects custom #prepare_record_attributes implementations for turbo stream requests" do
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
      handler = MartenTurbo::Handlers::RecordCreateSpec::TestWithPreparedAttributesHandler.new(request)

      response = handler.post

      response.content.strip.should contain "<div class=\"tag-name\">prepared-newtag</div>"
      handler.record.not_nil!.name.should eq "prepared-newtag"
    end

    it "calls custom #save_record implementations" do
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
      handler = MartenTurbo::Handlers::RecordCreateSpec::TestWithCustomSaveHandler.new(request)

      response = handler.post

      handler.save_record_called?.should be_true
      handler.record.not_nil!.name.should eq "saved-newtag"
      response.content.strip.should contain "<div class=\"tag-name\">saved-newtag</div>"
    end

    it "runs inherited callbacks in the expected order" do
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
      handler = MartenTurbo::Handlers::RecordCreateSpec::TestWithCallbacksHandler.new(request)

      handler.post

      handler.executed_callbacks.should eq ["before_validation", "after_successful_validation", "before_render"]
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
    turbo_invalid_stream_name "tags/create_errors.turbo_stream.html"
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

  class TestWithCustomRenderMethod < MartenTurbo::Handlers::RecordCreate
    model Tag
    schema TagCreateSchema
    success_route_name "dummy"
    template_name "tags/create.html"

    def turbo_stream
      MartenTurbo::TurboStream.append("messages", "<div>New Message</div>")
    end
  end

  class TestWithCountedTurboStreamHandler < MartenTurbo::Handlers::RecordCreate
    model Tag
    schema TagCreateSchema
    success_route_name "dummy"
    template_name "tags/create.html"

    getter turbo_stream_calls : Int32 = 0

    def turbo_stream
      @turbo_stream_calls += 1

      MartenTurbo::TurboStream.append("messages", "<div>New Message</div>")
    end
  end

  class TestWithCountedTurboStreamAndTemplateHandler < MartenTurbo::Handlers::RecordCreate
    model Tag
    schema TagCreateSchema
    success_route_name "dummy"
    template_name "tags/create.html"
    turbo_stream_name "tags/create.turbo_stream.html"

    getter turbo_stream_calls : Int32 = 0

    def turbo_stream
      @turbo_stream_calls += 1

      MartenTurbo::TurboStream.append("messages", "<div>New Message</div>")
    end
  end

  class TestWithoutSuccessRouteHandler < MartenTurbo::Handlers::RecordCreate
    model Tag
    schema TagCreateSchema
    template_name "tags/create.html"
    turbo_stream_name "tags/create.turbo_stream.html"
  end

  class TestWithPreparedAttributesHandler < MartenTurbo::Handlers::RecordCreate
    model Tag
    schema TagCreateSchema
    success_route_name "dummy"
    template_name "tags/create.html"
    turbo_stream_name "tags/create.turbo_stream.html"

    def prepare_record_attributes
      attributes = super
      attributes["name"] = "prepared-#{attributes["name"]}"
      attributes
    end
  end

  class TestWithCustomSaveHandler < MartenTurbo::Handlers::RecordCreate
    model Tag
    schema TagCreateSchema
    success_route_name "dummy"
    template_name "tags/create.html"
    turbo_stream_name "tags/create.turbo_stream.html"

    getter? save_record_called : Bool = false

    def save_record : Marten::DB::Model
      @save_record_called = true

      Tag.create!(name: "saved-#{schema.validated_data["name"]}")
    end
  end

  class TestWithCallbacksHandler < MartenTurbo::Handlers::RecordCreate
    model Tag
    schema TagCreateSchema
    success_route_name "dummy"
    template_name "tags/create.html"
    turbo_stream_name "tags/create.turbo_stream.html"

    getter executed_callbacks : Array(String) = [] of String

    before_schema_validation :track_before_validation
    after_successful_schema_validation :track_after_successful_validation
    before_render :track_before_render

    private def track_before_validation : Nil
      @executed_callbacks << "before_validation"
    end

    private def track_after_successful_validation : Nil
      @executed_callbacks << "after_successful_validation"
    end

    private def track_before_render : Nil
      @executed_callbacks << "before_render"
    end
  end
end
