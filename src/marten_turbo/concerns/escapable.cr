require "html"

module MartenTurbo
  # Provides HTML escaping for values written into generated HTML attributes.
  module Escapable
    # Escapes a value so that it can be safely interpolated into an HTML attribute.
    private def escape_attribute(value) : String
      HTML.escape(value.to_s)
    end
  end
end
