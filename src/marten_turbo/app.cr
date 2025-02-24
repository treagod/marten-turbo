require "./concerncs/**"
require "./turbo_stream"
require "./ext/**"
require "./handlers/**"
require "./template/**"

module MartenTurbo
  class App < Marten::App
    label "marten_turbo"

    def setup
      Marten::Template::Tag.register "dom_id", Template::Tag::DomId
      Marten::Template::Tag.register "turbo_stream", Template::Tag::TurboStream
    end
  end
end
