module MartenTurbo
  module Template
    module Tag
      class DomId < Marten::Template::Tag::Base
        include Marten::Template::Tag::CanSplitSmartly
        include Identifiable

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
          create_dom_id @instance_name.resolve(context), @prefix.try(&.resolve(context))
        end
      end
    end
  end
end
