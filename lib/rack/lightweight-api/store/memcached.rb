module Rack
  class LightweightAPI
    module Cache
      module Store
        ##
        # Memcached Cache Store
        #
        class Memcached
          ##
          # Initialize Memcached store with client connection.
          #
          # @param client
          #   instance of Memcached library
          #
          # @example
          #   ::Rack::LightweightAPI.cache = ::Rack::LightweightAPI::Cache::Store::Memcached.new(::Memcached.new('127.0.0.1:11211'))
          #
          # @api public
          def initialize(client)
            @backend = client
          rescue
            raise
          end

          ##
          # Return the a value for the given key
          #
          # @param [String] key
          #   cache key to retrieve value
          #
          # @example
          #   # with MyApp.cache.set('records', records)
          #   MyApp.cache.get('records')
          #
          # @api public
          def get(key)
            @backend.get(key)
          rescue ::Memcached::NotFound
            nil
          end

          ##
          # Set the value for a given key and optionally with an expire time
          # Default expiry time is 86400.
          #
          # @param [String] key
          #   cache key
          # @param value
          #   value of cache key
          # @param opts
          #   value of opts. (current options => :expires_in)
          #
          # @api public
          def set(key, value, opts = nil)
            begin  
              if opts && opts[:expires_in]
                expires_in = opts[:expires_in].to_i
                @backend.set(key, value, expires_in)
              else
                @backend.set(key, value)
              end
            rescue ::Memcached
              # 
            end
          end

          ##
          # Delete the value for a given key
          #
          # @param [String] key
          #   cache key
          #
          # @api public
          def delete(key)
            @backend.delete(key)
          end

          ##
          # Reinitialize your cache
          #
          # @api public
          def flush
            @backend.respond_to?(:flush_all) ? @backend.flush_all : @backend.flush
          end
        end # Memcached
      end # Store
    end # Cache
  end # LightweightAPI
end # Rack