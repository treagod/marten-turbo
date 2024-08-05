module MartenTurbo
  module Template
    module ContextProducer
      class TurboNative < Marten::Template::ContextProducer
        def produce(request : Marten::HTTP::Request? = nil)
          {"turbo_native?" => request.turbo_native_app?}
        end
      end
    end
  end
end
