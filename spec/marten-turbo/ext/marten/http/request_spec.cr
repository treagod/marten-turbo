require "./spec_helper"

describe Marten::HTTP::Request do
  describe "#turbo?" do
    it "correctly returns true if the request is a turbo request" do
      request = Marten::HTTP::Request.new(
        method: "GET",
        resource: "/test/xyz",
        headers: HTTP::Headers{"Accept" => "text/vnd.turbo-stream.html"},
      )

      request.turbo?.should be_true
    end

    it "correctly returns false if the request is not a turbo request" do
      request = Marten::HTTP::Request.new(
        method: "GET",
        resource: "/test/xyz",
        headers: HTTP::Headers{"Accept" => "text/html"},
      )

      request.turbo?.should be_false
    end
  end
end
