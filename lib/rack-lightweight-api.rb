# encoding: utf-8

require 'rack/lightweight-api'

module Rack
  class LightweightAPI
    
    @@_cache_store      = nil
    @@_fallback_ttl     = 3600 # 1 hora
    @@_bypass_routes    = nil
    
    def self.cache
      @@_cache_store
    end   
    def self.cache=(cache_store)
      @@_cache_store = cache_store
    end

    def self.fallback_ttl
      @@_fallback_ttl
    end   
    def self.fallback_ttl=(fallback_ttl)
      @@_fallback_ttl = fallback_ttl
    end

    def self.bypass_routes
      @@_bypass_routes
    end   
    def self.bypass_routes=(bypass_routes)
      @@_bypass_routes = bypass_routes
    end

    module Cache
      autoload :Store, 'rack/lightweight-api/store'
    end
  end
end