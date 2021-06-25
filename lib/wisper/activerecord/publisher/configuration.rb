module Wisper
  module ActiveRecord
    module Publisher
      def self.configuration
        @configuration ||= Configuration.new
      end

      def self.configure
        yield configuration
      end

      class Configuration
        attr_reader :default_broadcast_events

        def initialize
          @default_broadcast_events = [:create, :update, :destroy]
        end

        def default_broadcast_events=(events)
          raise ArgumentError, "default_broadcast_events must be an array" unless events.is_a?(Array)

          @default_broadcast_events = events
        end
      end
    end
  end
end
