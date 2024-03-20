require "./spec_helper"

describe MartenTurbo::Handlers::RecordCreate do
  describe "#post" do
    it "deletes the record and returns the expected redirect when no turbo request was made and no template is given" do
      tag_1 = Tag.create!(name: "Tag 1")
      tag_2 = Tag.create!(name: "Tag 2")

      params = Marten::Routing::MatchParameters{"pk" => tag_1.pk!}
      request = Marten::HTTP::Request.new(
        ::HTTP::Request.new(
          method: "GET",
          resource: "",
          headers: HTTP::Headers{
            "Accept" => "text/html",
            "Host"   => "example.com",
          }
        )
      )
      handler = MartenTurbo::Handlers::RecordDeleteSpec::TestWithoutTemplateHandler.new(request, params)

      response = handler.post

      response.should be_a Marten::HTTP::Response::Found
      Tag.get(pk: tag_1.pk).should be_nil
      Tag.get(pk: tag_2.pk).should eq tag_2
    end

    it "deletes the record and returns the expected redirect when no turbo request was made and a template is given" do
      tag_1 = Tag.create!(name: "Tag 1")
      tag_2 = Tag.create!(name: "Tag 2")

      params = Marten::Routing::MatchParameters{"pk" => tag_1.pk!}
      request = Marten::HTTP::Request.new(
        ::HTTP::Request.new(
          method: "GET",
          resource: "",
          headers: HTTP::Headers{
            "Accept" => "text/html",
            "Host"   => "example.com",
          }
        )
      )
      handler = MartenTurbo::Handlers::RecordDeleteSpec::TestHandler.new(request, params)

      response = handler.post

      response.should be_a Marten::HTTP::Response::Found
      Tag.get(pk: tag_1.pk).should be_nil
      Tag.get(pk: tag_2.pk).should eq tag_2
    end

    it "deletes the record and returns the expected redirect when a turbo request was made and no template is given" do
      tag_1 = Tag.create!(name: "Tag 1")
      tag_2 = Tag.create!(name: "Tag 2")

      params = Marten::Routing::MatchParameters{"pk" => tag_1.pk!}
      request = Marten::HTTP::Request.new(
        ::HTTP::Request.new(
          method: "GET",
          resource: "",
          headers: HTTP::Headers{
            "Accept" => "text/html",
            "Host"   => "example.com",
          }
        )
      )
      handler = MartenTurbo::Handlers::RecordDeleteSpec::TestWithoutTemplateHandler.new(request, params)

      response = handler.post

      response.should be_a Marten::HTTP::Response::Found
      Tag.get(pk: tag_1.pk).should be_nil
      Tag.get(pk: tag_2.pk).should eq tag_2
    end

    it "deletes the record and returns a delete turbo stream when a turbo request was made and a template is given" do
      tag_1 = Tag.create!(name: "Tag 1")

      params = Marten::Routing::MatchParameters{"pk" => tag_1.pk!}
      request = Marten::HTTP::Request.new(
        ::HTTP::Request.new(
          method: "GET",
          resource: "",
          headers: HTTP::Headers{
            "Accept" => "text/vnd.turbo-stream.html",
            "Host"   => "example.com",
          }
        )
      )
      handler = MartenTurbo::Handlers::RecordDeleteSpec::TestHandler.new(request, params)

      response = handler.post

      response.should_not be_a Marten::HTTP::Response::Found
      response.content.strip.should contain "<turbo-stream action=\"remove\" " \
                                            "target=\"tag_#{tag_1.pk!}\"></turbo-stream>"
    end
  end
end

module MartenTurbo::Handlers::RecordDeleteSpec
  class TestHandler < MartenTurbo::Handlers::RecordDelete
    model Tag
    success_route_name "dummy"
    template_name "tags/delete.html"
    turbo_stream_name "tags/delete.turbo_stream.html"
  end

  class TestWithoutTemplateHandler < MartenTurbo::Handlers::RecordDelete
    model Tag
    success_route_name "dummy"
    template_name "tags/delete.html"
  end
end
