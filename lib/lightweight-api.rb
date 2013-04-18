# encoding: utf-8

require 'rack/lightweight-api'

module Rack
  class LightweightAPI
    
    @@_cache_store      = nil
    @@_default_ttl      = 3600 # 1 hora
    @@_exclude_routes   = nil
    
    def self.cache
      @@_cache_store
    end   
    def self.cache=(cache_store)
      @@_cache_store = cache_store
    end

    def self.default_ttl
      @@_default_ttl
    end   
    def self.default_ttl=(default_ttl)
      @@_default_ttl = default_ttl
    end

    def self.exclude_routes
      @@_exclude_routes
    end   
    def self.exclude_routes=(exclude_routes)
      @@_exclude_routes = exclude_routes
    end

    module Cache
      autoload :Store, 'rack/lightweight-api/store'
    end
  end
end