# encoding: utf-8

require 'rack/utils'

module Rack

  class LightweightAPI < ::Rack::ConditionalGet

    def call(env)
      @@_logger = env['rack.logger']

      middleware_enable = middleware_enable?(env)

      case env['REQUEST_METHOD']
      when "GET", "HEAD"

        if middleware_enable
          response_headers = @@_cache_store.get(env['REQUEST_URI'])
          
          unless response_headers.nil?
            response_headers = Utils::HeaderHash.new(response_headers)
            return http_response_304(env['REQUEST_URI'], response_headers) if conditional_get_allowed?(env, response_headers)
          end

          log "calling app for #{env['REQUEST_URI']}"
        end

        status, response_headers, body = @app.call(env)
        response_headers = Utils::HeaderHash.new(response_headers)
        
        if status == 200
          store_in_cache(env['REQUEST_URI'], response_headers) if middleware_enable && store_in_cache_allowed?(env, response_headers)
          return http_response_304(env['REQUEST_URI'], response_headers) if conditional_get_allowed?(env, response_headers)
        end

        [status, response_headers, body]

      when "PUT"
        
        status, response_headers, body = @app.call(env)
        remove_from_cache(env['REQUEST_URI']) if middleware_enable && [200, 202].include?(status)
        [status, response_headers, body]

      when "DELETE"

        status, response_headers, body = @app.call(env)
        remove_from_cache(env['REQUEST_URI']) if middleware_enable && [200, 202, 204].include?(status)
        [status, response_headers, body]

      else
        @app.call(env)
      end
    end

    private

    def middleware_enable?(env)
      (@@_cache_store.nil? || bypass_by_route?(env['REQUEST_URI'])) ? false : true
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

    def conditional_get_allowed?(env, response_headers)
      header_contains_directive?(env['HTTP_CACHE_CONTROL'], /no\-cache/) ? false : fresh?(env, response_headers)
    end

    def http_response_304(request_uri, response_headers)
      log "halting 304 for #{request_uri}"
      response_headers.delete('Content-Type')
      response_headers.delete('Content-Length')
      response_headers.delete('Cache-Control')
      [304, response_headers, []]
    end

    def store_in_cache(request_uri, response_headers)
      log "storing response_headers for #{request_uri}"
      # TODO: Store based on the cache control response header if it's present
      @@_cache_store.set(request_uri, response_headers, :expires_in => @@_fallback_ttl)
    end

    def store_in_cache_allowed?(env, response_headers)
      request_headers_allow_store?(env) && 
      response_headers_allow_store?(response_headers) && 
      response_headers_are_cacheable?(response_headers)
    end

    def request_headers_allow_store?(env)
      cache_control = env['HTTP_CACHE_CONTROL']
      ! header_contains_directive?(cache_control, /no\-store/) && ! header_contains_directive?(cache_control, /no\-cache/)
    end

    def response_headers_allow_store?(response_headers)
      cache_control = response_headers['Cache-Control']
      ! header_contains_directive?(cache_control, /no\-store/) && ! header_contains_directive?(cache_control, /no\-cache/)
    end

    def header_contains_directive?(header_value, directive_regex)
      header_value.is_a?(String) && header_value.downcase =~ directive_regex
    end

    def response_headers_are_cacheable?(response_headers)
      response_headers.has_key?('ETag') || response_headers.has_key?('Last-Modified')
    end

    def remove_from_cache(request_uri)
      log "cleaning cache for #{request_uri}"
      @@_cache_store.delete(request_uri)
    end

    def log(message)
      @@_logger.debug "\033[1;31m[LightweightAPI]\033[0;36m #{message}\033[0m" unless @@_logger.nil?
    end

  end

end