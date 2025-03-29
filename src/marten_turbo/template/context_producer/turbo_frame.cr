module MartenTurbo
  module Template
    module ContextProducer
      class TurboFrame < Marten::Template::ContextProducer
        def produce(request : Marten::HTTP::Request? = nil)
          {"turbo_frame?" => request.turbo_frame?} if request
        end
      end
    end
  end
end
