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

  describe "#turbo_native_app?" do
    it "correctly returns false if the request is not a turbo native request" do
      request = Marten::HTTP::Request.new(
        method: "GET",
        resource: "/test/xyz",
        headers: HTTP::Headers{"Accept" => "text/html", "User-Agent" => "Custom-Agent"},
      )

      request.turbo_native_app?.should be_false
    end

    it "correctly returns true if the request is a turbo native request" do
      request = Marten::HTTP::Request.new(
        method: "GET",
        resource: "/test/xyz",
        headers: HTTP::Headers{"Accept" => "text/html", "User-Agent" => "Custom Turbo Native Agent"},
      )

      request.turbo_native_app?.should be_true
    end

    it "correctly returns false if the request headers do not contain a user agent" do
      request = Marten::HTTP::Request.new(
        method: "GET",
        resource: "/test/xyz",
        headers: HTTP::Headers{"Accept" => "text/html"},
      )

      request.turbo_native_app?.should be_false
    end
  end
end
