module MartenTurbo
  module Template
    module Tag
      class DomId < Marten::Template::Tag::Base
        include Marten::Template::Tag::CanSplitSmartly

        @instance_name : Marten::Template::Variable
        @prefix : Marten::Template::Variable? = nil

        def initialize(parser : Marten::Template::Parser, source : String)
          parts = split_smartly(source)

          unless {2, 3}.includes?(parts.size)
            raise Marten::Template::Errors::InvalidSyntax.new(
              "Malformed dom_id tag: one or two arguments must be provided"
            )
          end

          @instance_name = Marten::Template::Variable.new(parts[1])
          @prefix = Marten::Template::Variable.new(parts[2]) if parts.size == 3
        end

        def render(context : Marten::Template::Context) : String
          instance = @instance_name.resolve(context)
          prefix = @prefix.try(&.resolve(context))

          if instance.raw.is_a? Marten::Model
            generate_id_for_model(instance.raw.as(Marten::Model), prefix)
          else
            dom_id = instance.to_s
            prefix ? "#{prefix.to_s}_#{dom_id}" : dom_id
          end
        end

        private def formatted_prefix(prefix, substitute = nil)
          prefix ? "#{prefix.to_s}_" : substitute ? "#{substitute}_" : ""
        end

        private def generate_id_for_model(model, prefix)
          identifier = model.class.name.downcase.gsub(/(?:\:\:|\.)/, '_')
          model.new_record? ? "#{formatted_prefix(prefix, "new")}#{identifier}" : "#{formatted_prefix(prefix)}#{identifier}_#{model.pk}"
        end
      end
    end
  end
end
