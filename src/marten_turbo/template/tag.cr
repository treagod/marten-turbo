require "./tag/**"

module MartenTurbo
  module Template
    module Tag
      Marten::Template::Tag.register "dom_id", DomId
    end
  end
end
