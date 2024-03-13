require "./handlers/**"
require "./models/**"
require "./schemas/**"

module MartenTurbo
  class App < Marten::App
    label "marten-turbo"
  end
end
