module CMSScanner
  module Cache
    # Cache Implementation using files
    class FileStore
      attr_reader :storage_path, :serializer

      # The serializer must have the 2 methods #load and #dump
      #   (Marshal and YAML have them)
      # YAML is Human Readable, contrary to Marshal which store in a binary format
      # Marshal does not need any "require"
      #
      # @param [ String ] storage_path
      # @param [ ] serializer
      def initialize(storage_path, serializer = Marshal)
        @storage_path = File.expand_path(storage_path)
        @serializer   = serializer

        FileUtils.mkdir_p(@storage_path) unless Dir.exist?(@storage_path)
      end

      # TODO: rename this to clear ?
      def clean
        Dir[File.join(storage_path, '*')].each do |f|
          File.delete(f) unless File.symlink?(f)
        end
      end

      # @param [ String ] key
      #
      # @return [ Mixed ]
      def read_entry(key)
        file_path = entry_path(key)

        serializer.load(File.read(file_path)) if File.exist?(file_path) && !expired_entry?(key)
      end

      # @param [ String ] key
      # @param [ Mixed ] data_to_store
      # @param [ Integer ] cache_ttl
      def write_entry(key, data_to_store, cache_ttl)
        return unless cache_ttl.to_i > 0

        File.write(entry_path(key), serializer.dump(data_to_store))
        File.write(entry_expiration_path(key), Time.now.to_i + cache_ttl)
      end

      # @param [ String ] key
      #
      # @return [ String ] The file path associated to the key
      def entry_path(key)
        File.join(storage_path, key)
      end

      # @param [ String ] key
      #
      # @return [ String ] The expiration file path associated to the key
      def entry_expiration_path(key)
        entry_path(key) + '.expiration'
      end

      private

      # @param [ String ] key
      #
      # @return [ Boolean ]
      def expired_entry?(key)
        File.read(entry_expiration_path(key)).to_i <= Time.now.to_i rescue true
      end
    end
  end
end
