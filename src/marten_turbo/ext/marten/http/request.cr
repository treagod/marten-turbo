class Marten::HTTP::Request
  def turbo?
    accepts? "text/vnd.turbo-stream.html"
  end

  def turbo_native_app?
    user_agent = @request.headers["User-Agent"]?
    user_agent.includes?("Turbo Native") if user_agent
  end
end
