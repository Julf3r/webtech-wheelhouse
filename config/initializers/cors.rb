Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins "https://julf3r.github.io", "http://localhost:5500"

    resource %r{\A/api/v1/services(?:/\d+)?\z},
             headers: :any,
             methods: [:get]
  end
end
