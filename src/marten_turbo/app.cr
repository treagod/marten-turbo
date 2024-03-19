require "./handlers/**"
require "./models/**"
require "./schemas/**"
require "./template/**"

module MartenTurbo
  class App < Marten::App
    label "marten_turbo"
  end
end
