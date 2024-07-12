require "./turbo_stream"
require "./ext/**"
require "./handlers/**"
require "./template/**"

module MartenTurbo
  class App < Marten::App
    label "marten_turbo"
  end
end
