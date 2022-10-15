# Implement basic health endpoint as rack middleware and insert it so it
# doesn't get logged (so there's not constant log activity for these requests).
class HealthEndpointMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    if env["PATH_INFO"] == "/_health"
      return [200, { "Content-Type" => "text/plain" }, ["OK"]]
    end

    @app.call(env)
  end
end

Rails.application.middleware.insert_before 0, HealthEndpointMiddleware
