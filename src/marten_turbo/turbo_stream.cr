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
    def action(action, target : String | Marten::Model, content)
      target_id = target.is_a?(String) ? target : dom_id(target.as(Marten::Model))
      @streams << <<-TURBO_STREAM_TAG
          <turbo-stream action="#{action}" target="#{target_id}">
            #{render_template_tag(content)}
          </turbo-stream>
        TURBO_STREAM_TAG

      self
    end

    # Creates a new TurboStream instance and adds a single action.
    #
    # ```
    # stream = MartenTurbo::TurboStream.new
    # stream.replace("append", Message.get!(pk: 1), "<div>Updated Message</div>")
    # ```
    def action(action, target : Marten::Model, content)
      action(action, dom_id(target), content)
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
  end
end
