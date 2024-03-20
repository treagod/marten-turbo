class Marten::HTTP::Request
  def turbo?
    accepts? "text/vnd.turbo-stream.html"
  end
end
