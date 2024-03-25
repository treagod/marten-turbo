module MartenTurbo
  module Template
    module Tag
      module Identifiable
        def create_dom_id(value : Marten::Template::Value, prefix : Marten::Template::Value? = nil)
          if value.raw.is_a? Marten::Model
            generate_id_for_model(value.raw.as(Marten::Model), prefix)
          else
            dom_id = value.to_s
            prefix ? "#{prefix}_#{dom_id}" : dom_id
          end
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
  end
end
