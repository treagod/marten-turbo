class Marten::HTTP::Request
  def turbo?
    accepts? "text/vnd.turbo-stream.html"
  end

  def turbo_native_app?
    user_agent = @request.headers["User-Agent"]?

    user_agent ? user_agent.includes?("Turbo Native") : false
  end
end
