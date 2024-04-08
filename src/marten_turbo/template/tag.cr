require "./tag/**"

module MartenTurbo
  module Template
    module Tag
      Marten::Template::Tag.register "dom_id", DomId
      Marten::Template::Tag.register "turbo_stream", TurboStream
    end
  end
end
