# encoding: utf-8

module Rack
  class LightweightAPI
    module Cache
      ##
      # Defines the available storage adapters for persisting the cache.
      #
      module Store
        # Default expiration edge.
        EXPIRES_EDGE = 3600

        autoload :Memcached, 'rack/lightweight-api/store/memcached'
        
      end # Store
    end # Cache
  end # LightweightAPI
end # Rack
