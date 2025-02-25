module MartenTurbo
  module Template
    module Tag
      class TurboStream < Marten::Template::Tag::Base
        include Marten::Template::Tag::CanSplitSmartly
        include Marten::Template::Tag::CanExtractKwargs
        include Identifiable

        @turbo_stream_nodes : Marten::Template::NodeSet?
        @action_filter : Marten::Template::FilterExpression
        @target_id : Marten::Template::Variable

        def initialize(parser : Marten::Template::Parser, source : String)
          parts = split_smartly(source)

          if parts.size < 3
            raise Marten::Template::Errors::InvalidSyntax.new(
              "Malformed turbo_stream tag: you must define an action and a target id"
            )
          end

          @action_filter = Marten::Template::FilterExpression.new(parts[1])

          @target_id = Marten::Template::Variable.new(parts[2])

          if parts[-1] == "do"
            @turbo_stream_nodes = parser.parse(up_to: {"end_turbo_stream"})
            parser.shift_token
            kwargs_parts = parts[2...-2]
          else
            kwargs_parts = parts[2..]
          end

          @kwargs = {} of String => Marten::Template::FilterExpression
          extract_kwargs(kwargs_parts.join(' ')).each do |key, value|
            @kwargs[key] = Marten::Template::FilterExpression.new(value)
          end
        end

        def render(context : Marten::Template::Context) : String
          action = @action_filter.resolve(context).to_s
          content = if turbo_stream_nodes = @turbo_stream_nodes
                      turbo_stream_nodes.render(context)
                    else
                      nil
                    end

          template = nil

          @kwargs.each do |param_name, param_expression|
            raw_param_value = param_expression.resolve(context).raw

            # Ensure that the raw param value can be used as an URL parameter.
            unless raw_param_value.is_a?(Marten::Routing::Parameter::Types)
              raise Marten::Template::Errors::UnsupportedType.new(
                "#{raw_param_value.class} objects cannot be used as URL parameters"
              )
            end

            if param_name == "template"
              unless raw_param_value.is_a?(String)
                raise Marten::Template::Errors::UnsupportedValue.new(
                  "Template name must resolve to a string, git a #{raw_param_value.class} instead."
                )
              end
              template = Marten.templates.get_template(raw_param_value)
            end
          end

          if template
            content = template.render(context)
          end

          target = @target_id.resolve(context)

          MartenTurbo::TurboStream.action(action, dom_id(target.raw), content).to_s
        end
      end
    end
  end
end
