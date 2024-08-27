module MartenTurbo
  module Identifiable
    @[Deprecated("Use `#dom_id` instead")]
    def create_dom_id(value, prefix : String | Symbol | Nil = nil)
      dom_id(value, prefix)
    end

    def dom_id(value, prefix : String | Symbol | Nil = nil)
      dom_id = value.to_s
      prefix ? "#{prefix}_#{dom_id}" : dom_id
    end

    @[Deprecated("Use `#dom_id` instead")]
    def create_dom_id(value : Marten::Model, prefix : String | Symbol | Nil = nil)
      dom_id(value, prefix)
    end

    def dom_id(value : Marten::Model, prefix : String | Symbol | Nil = nil)
      generate_id_for_model(value, prefix)
    end

    private def formatted_prefix(prefix)
      prefix ? "#{prefix}_" : ""
    end

    private def generate_id_for_model(model, prefix)
      identifier = model.class.name.downcase.gsub(RE_NAMESPACE_IDENTIFIER, '_')
      if model.new_record?
        "#{formatted_prefix(prefix)}new_#{identifier}"
      else
        "#{formatted_prefix(prefix)}#{identifier}_#{model.pk}"
      end
    end

    RE_NAMESPACE_IDENTIFIER = /(?:\:\:|\.)/
  end
end
