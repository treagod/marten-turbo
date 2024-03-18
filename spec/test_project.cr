require "./test_project/**"

ENV_SETTINGS_FILENAME = ".spec.env.json"

ENV_SETTINGS = if File.exists?(ENV_SETTINGS_FILENAME)
                 Hash(String, Int32 | String).from_json(File.read(ENV_SETTINGS_FILENAME))
               else
                 Hash(String, Int32 | String).new
               end

Marten.configure :test do |config|
  config.installed_apps = [
    MartenTurbo::App,
    TestApp,
  ]
  config.secret_key = "__insecure_#{Random::Secure.random_bytes(32).hexstring}__"
  config.log_level = ::Log::Severity::None
  config.database do |db|
    db.backend = :sqlite
    db.name = ":memory:"
  end
end
