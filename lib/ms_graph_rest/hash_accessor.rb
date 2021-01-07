module MsGraphRest
  class HashAccessor
    def initialize(hash)
      @_raw_hash = hash&.to_h || {}
      @_method_to_key = hash.keys.each_with_object({}) do |key, mapping|
        normalize_key = key.gsub('@', '').gsub('.', '_')
        mapping[normalize_key] = key
        mapping[normalize_key.underscore] = key
      end
    end

    def [](key)
      _val(@_raw_hash[key])
    end

    def to_h
      to_hash
    end

    def to_hash
      @_raw_hash
    end

    private

    def _val(val)
      if val.is_a?(Hash)
        HashAccessor.new(val)
      elsif val.is_a?(Array)
        val.map { |v| _val(v) }
      else
        val
      end
    end

    def _method_to_key(method_name)
      @_method_to_key[method_name.to_s]
    end

    def method_missing(method_name, *arguments, &block)
      camelize_key = _method_to_key(method_name)
      if camelize_key
        self[camelize_key]
      else
        super
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      camelize_key = _method_to_key(method_name)
      !camelize_key.nil? || super
    end
  end
end
