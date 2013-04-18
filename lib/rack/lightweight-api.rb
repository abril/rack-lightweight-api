# encoding: utf-8

require 'rack/utils'

module Rack

  class LightweightAPI < ::Rack::ConditionalGet

    def call(env)
      middleware_active = middleware_active_for_request?(env['REQUEST_URI'])

      case env['REQUEST_METHOD']
      when "GET", "HEAD"

        if middleware_active
          headers = @@_cache_store.get(env['REQUEST_URI'])
          
          unless headers.nil?
            headers = Utils::HeaderHash.new(headers)
            return http_response_304(env['REQUEST_URI'], headers) if fresh?(env, headers)
          end
        end

        STDOUT.puts "[LightweightAPI] Calling app for #{env['REQUEST_URI']}"

        status, headers, body = @app.call(env)
        headers = Utils::HeaderHash.new(headers)
        
        if status == 200
          store_in_cache(env['REQUEST_URI'], headers) if middleware_active
          return http_response_304(env['REQUEST_URI'], headers) if fresh?(env, headers)
        end

        [status, headers, body]

      else
        @app.call(env)
      end
    end

    private

    def middleware_active_for_request?(request_uri)
      return false if @@_cache_store.nil?
      return true  if @@_exclude_routes.nil?
      excluded_route?(request_uri) ? false : true
    end

    def excluded_route?(request_uri)
      @@_exclude_routes.each do |route|
        if route =~ request_uri
          STDOUT.puts "[LightweightAPI] Bypassing excluded route #{request_uri}"
          return true
        end
      end
      false
    end

    def http_response_304(request_uri, headers)
      STDOUT.puts "[LightweightAPI] Halting 304 for #{request_uri}"
      headers.delete('Content-Type')
      headers.delete('Content-Length')
      headers.delete('Cache-Control')
      [304, headers, []]
    end

    def store_in_cache(request_uri, headers)
      if (headers.has_key?('ETag') || headers.has_key?('Last-Modified'))
        @@_cache_store.set(request_uri, headers, :expires_in => @@_default_ttl)
      end
    end

  end

end