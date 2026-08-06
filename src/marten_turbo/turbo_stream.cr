module MartenTurbo
  class TurboStream
    include Identifiable

    ACTIONS = %w[append prepend replace update remove before after]

    def initialize
      @streams = [] of String
    end

    def self.new(&)
      with new yield
    end

    # Creates a new TurboStream instance and adds a single action.
    #
    # ```
    # stream = MartenTurbo::TurboStream.action("append", "messages", "<div>New Message</div>")
    # ```
    def self.action(action, target_id, content)
      new.action(action, target_id, content)
    end

    # Creates a new TurboStream instance and adds a single action.
    #
    # ```
    # stream = MartenTurbo::TurboStream.new
    # stream.action("append", "messages", "<div>New Message</div>")
    # ```
    def action(action, target : String | Symbol | Marten::Model, content)
      if target.is_a?(Marten::Model)
        @streams << build_stream_tag(action, "target", dom_id(target), content)
      else
        target_value = target.to_s
        attribute_name = selector_target?(target_value) ? "targets" : "target"
        @streams << build_stream_tag(action, attribute_name, target_value, content)
      end

      self
    end

    {% for action in ACTIONS %}
      # Adds a turbo stream {{ action.id }} action to the streams array.
      def {{ action.id }}(target, content : String? = nil)
        action("{{ action.id }}", target, content)

        self
      end

      # Creates a a turbo stream instance with a {{ action.id }} action
      # already in its array.
      def self.{{ action.id }}(target, content : String? = nil)
        self.new.action("{{ action.id }}", target, content)
      end
    {% end %}

    def to_s
      @streams.join("\n")
    end

    def to_s(io : IO)
      @streams.each do |stream|
        io << stream
        io << "\n"
      end
    end

    private def render_template_tag(content)
      return "" unless content

      <<-TEMPLATE_TAG
          <template>
            #{content}
          </template>
        TEMPLATE_TAG
    end

    private def build_stream_tag(action, attribute_name : String, target_value : String, content)
      <<-TURBO_STREAM_TAG
          <turbo-stream action="#{action}" #{attribute_name}="#{target_value}">
            #{render_template_tag(content)}
          </turbo-stream>
        TURBO_STREAM_TAG
    end

    private def selector_target?(target : String) : Bool
      target.starts_with?('.')
    end
  end
end
