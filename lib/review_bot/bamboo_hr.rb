module ReviewBot
  class BambooHR
    API_ROOT = 'https://api.bamboohr.com/'.freeze

    def initialize(api_key:, subdomain:)
      @api_key = api_key
      @subdomain = subdomain
    end

    def whos_out(start_date:, end_date: start_date)
      get('time_off/whos_out', start: start_date.to_s, end: end_date.to_s)
    end

    private

    attr_reader :api_key, :subdomain

    def get(path, params = {})
      @reviews ||= begin
        conn = Faraday.new(
          url: API_ROOT,
          headers: { Accept: 'application/json' }
        )
        conn.basic_auth(api_key, ' ')
        response = conn.get("/api/gateway.php/#{subdomain}/v1/#{path}", params)
        JSON.parse(response.body)
      end
    end
  end
end
