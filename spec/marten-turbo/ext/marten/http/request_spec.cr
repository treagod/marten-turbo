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

    it "returns true for the Accept header Turbo sends with form submissions" do
      request = Marten::HTTP::Request.new(
        method: "POST",
        resource: "/test/xyz",
        headers: HTTP::Headers{"Accept" => "text/vnd.turbo-stream.html, text/html, application/xhtml+xml"},
      )

      request.turbo?.should be_true
    end

    it "returns false for a wildcard Accept header" do
      request = Marten::HTTP::Request.new(
        method: "POST",
        resource: "/test/xyz",
        headers: HTTP::Headers{"Accept" => "*/*"},
      )

      request.turbo?.should be_false
    end

    it "returns false for the Accept header of a regular browser form submission" do
      request = Marten::HTTP::Request.new(
        method: "POST",
        resource: "/test/xyz",
        headers: HTTP::Headers{"Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"},
      )

      request.turbo?.should be_false
    end

    it "returns false if the request has no Accept header" do
      request = Marten::HTTP::Request.new(method: "POST", resource: "/test/xyz", headers: HTTP::Headers.new)

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

    it "correctly returns true if the request contains a turbo-frame header" do
      request = Marten::HTTP::Request.new(
        method: "GET",
        resource: "/test/xyz",
        headers: HTTP::Headers{"Accept" => "text/vnd.turbo-stream.html", "turbo-frame" => "form"},
      )

      request.turbo_frame?.should be_true
    end

    it "correctly returns false if the request doesn't contains a turbo-frame header" do
      request = Marten::HTTP::Request.new(
        method: "GET",
        resource: "/test/xyz",
        headers: HTTP::Headers{"Accept" => "text/vnd.turbo-stream.html"},
      )

      request.turbo_frame?.should be_false
    end
  end
end
