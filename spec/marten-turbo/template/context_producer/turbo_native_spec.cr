require "../../spec_helper"

describe MartenTurbo::Template::ContextProducer::TurboNative do
  describe "#produce" do
    it "returns the expected hash" do
      request = Marten::HTTP::Request.new(
        ::HTTP::Request.new(
          method: "GET",
          resource: "/test/xyz",
          body: "foo=bar",
          headers: HTTP::Headers{
            "User-Agent" => "Custom Turbo Native Application",
          }
        )
      )

      context_producer = MartenTurbo::Template::ContextProducer::TurboNative.new
      context_producer.produce(request).should eq({"turbo_native?" => request.turbo_native_app?})
    end
  end
end
