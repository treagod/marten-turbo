require "../../spec_helper"

describe MartenTurbo::Template::ContextProducer::TurboFrame do
  describe "#produce" do
    it "returns the expected hash" do
      request = Marten::HTTP::Request.new(
        ::HTTP::Request.new(
          method: "GET",
          resource: "/test/xyz",
          body: "foo=bar",
          headers: HTTP::Headers{
            "turbo-frame" => "form",
          }
        )
      )

      context_producer = MartenTurbo::Template::ContextProducer::TurboFrame.new
      context_producer.produce(request).should eq({"turbo_frame?" => request.turbo_frame?})
    end
  end
end
