# Rate limiting and request throttling.
# See https://github.com/rack/rack-attack for full configuration options.

class Rack::Attack
  ### Throttle login attempts by IP ──────────────────────────────────────────
  # 5 attempts per 60 seconds per IP on the login endpoint.
  throttle("logins/ip", limit: 5, period: 60.seconds) do |req|
    req.ip if req.path == "/session" && req.post?
  end

  ### Throttle login attempts by email ───────────────────────────────────────
  # 5 attempts per 60 seconds per email (prevents credential stuffing).
  throttle("logins/email", limit: 5, period: 60.seconds) do |req|
    if req.path == "/session" && req.post?
      req.params.dig("email")&.to_s&.strip&.downcase&.presence
    end
  end

  ### Throttle signup by IP ──────────────────────────────────────────────────
  # 3 accounts per hour per IP.
  throttle("signups/ip", limit: 3, period: 1.hour) do |req|
    req.ip if req.path == "/users" && req.post?
  end

  ### General request throttle ───────────────────────────────────────────────
  # 300 requests per 5 minutes per IP (general abuse prevention).
  throttle("requests/ip", limit: 300, period: 5.minutes) do |req|
    req.ip unless req.path.start_with?("/assets", "/up")
  end

  ### Custom throttle response ───────────────────────────────────────────────
  self.throttled_responder = lambda do |req|
    now = req.env["rack.attack.match_data"][:epoch_time]
    retry_after = req.env["rack.attack.match_data"][:period] - (now % req.env["rack.attack.match_data"][:period])

    [
      429,
      { "Content-Type" => "text/plain", "Retry-After" => retry_after.to_s },
      [ "Rate limit exceeded. Try again in #{retry_after} seconds.\n" ]
    ]
  end
end
