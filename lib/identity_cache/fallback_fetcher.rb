module IdentityCache
  class FallbackFetcher
    attr_accessor :cache_backend

    def initialize(cache_backend)
      @cache_backend = cache_backend
    end

    def write(key, value)
      @cache_backend.write(key, value)
    end

    def delete(key)
      @cache_backend.delete(key)
    end

    def clear
      @cache_backend.clear
    end

    def fetch_multi(keys, &block)
      results = @cache_backend.read_multi(*keys)
      missed_keys = keys - results.keys
      unless missed_keys.empty?
        replacement_results = yield missed_keys
        missed_keys.zip(replacement_results) do |key, replacement_result|
          @cache_backend.write(key, replacement_result)
          results[key] = replacement_result
        end
      end
      results
    end

    def fetch(key)
      result = @cache_backend.read(key)
      if result.nil?
        result = yield
        @cache_backend.write(key, result)
      end
      result
    end
  end
end
