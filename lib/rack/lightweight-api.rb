# encoding: utf-8

require 'rack/utils'

module Rack

  class LightweightAPI < ::Rack::ConditionalGet

    def call(env)
      @@_logger = env['rack.logger']

      middleware_active = middleware_active_for_request?(env)

      case env['REQUEST_METHOD']
      when "GET", "HEAD"

        if middleware_active
          headers = @@_cache_store.get(env['REQUEST_URI'])
          
          unless headers.nil?
            headers = Utils::HeaderHash.new(headers)
            return http_response_304(env['REQUEST_URI'], headers) if fresh?(env, headers)
          end

          log "calling app for #{env['REQUEST_URI']}"
        end

        status, headers, body = @app.call(env)
        headers = Utils::HeaderHash.new(headers)
        
        if status == 200
          store_in_cache(env['REQUEST_URI'], headers) if middleware_active
          return http_response_304(env['REQUEST_URI'], headers) if fresh?(env, headers)
        end

        [status, headers, body]

      when "PUT"
        
        status, headers, body = @app.call(env)
        remove_from_cache(env['REQUEST_URI']) if middleware_active && [200, 202].include?(status)
        [status, headers, body]

      when "DELETE"

        status, headers, body = @app.call(env)
        remove_from_cache(env['REQUEST_URI']) if middleware_active && [200, 202, 204].include?(status)
        [status, headers, body]

      else
        @app.call(env)
      end
    end

    private

    def middleware_active_for_request?(env)
      (@@_cache_store.nil? || bypass_by_route?(env['REQUEST_URI']) || bypass_by_headers?(env) ? false : true)
    end

    def bypass_by_route?(request_uri)
      return true if @@_bypass_routes.nil?
      @@_bypass_routes.each do |bypass_route|
        if bypass_route =~ request_uri
          log "bypass_by_route? hit #{request_uri}"
          return true
        end
      end
      false
    end

    def bypass_by_headers?(env)
      return true if @@_bypass_headers.nil?
      @@_bypass_headers.each do |bypass_header|
        if env.has_key?('HTTP_' + bypass_header.upcase.gsub(/\-/, '_'))
          log "bypass_by_headers? hit #{bypass_header}"
          return true
        end
      end
      false
    end

    def http_response_304(request_uri, headers)
      log "halting 304 for #{request_uri}"
      headers.delete('Content-Type')
      headers.delete('Content-Length')
      headers.delete('Cache-Control')
      [304, headers, []]
    end

    def store_in_cache(request_uri, headers)
      if (headers.has_key?('ETag') || headers.has_key?('Last-Modified'))
        log "storing headers for #{request_uri}"
        @@_cache_store.set(request_uri, headers, :expires_in => @@_fallback_ttl)
      end
    end

    def remove_from_cache(request_uri)
      log "cleaning cache for #{request_uri}"
      @@_cache_store.delete(request_uri)
    end

    def log(message)
      @@_logger.debug "\033[1;31m[LightweightAPI]\033[0;36m #{message}\033[0m" if @@_logger.respond_to?(:debug)
    end

  end

end