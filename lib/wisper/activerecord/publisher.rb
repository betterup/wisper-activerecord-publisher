require 'wisper/activerecord/publisher/version'
require 'wisper/activerecord/publisher/configuration'
require 'active_record'
require 'wisper'

module Wisper
  module ActiveRecord
    # ActiveRecord extension to automatically publish events for CRUD lifecycle
    # see https://github.com/krisleech/wisper/wiki/Rails-CRUD-with-ActiveRecord
    # see https://github.com/krisleech/wisper-activerecord
    module Publisher
      extend ActiveSupport::Concern

      included do
        include Wisper::Publisher

        # NOTE: do not need to silence deprecations on Rails 5+
        ActiveSupport::Deprecation.silence do
          after_commit :broadcast_create, on: :create, if: -> { should_broadcast?(:create) }
          after_commit :broadcast_update, on: :update, if: -> { should_broadcast?(:update) }
          after_commit :broadcast_destroy, on: :destroy, if: -> { should_broadcast?(:destroy) }
        end

        class_attribute :wisper_activerecord_publisher_broadcast_events

        def self.broadcast_on(*events)
          return self.wisper_activerecord_publisher_broadcast_events = [] if events == [:none]

          events.each do |event|
            raise ArgumentError, "Unknown broadcast event '#{event}'" unless [:create, :update, :destroy].include?(event)
          end

          self.wisper_activerecord_publisher_broadcast_events = events
        end
      end

      private

      # broadcast MODEL_created event to subscribed listeners
      def broadcast_create
        broadcast broadcast_event_name(:created), self
      end

      # broadcast MODEL_updated event to subscribed listeners
      # pass the set of changes for background jobs to know what changed
      # see https://github.com/krisleech/wisper-activerecord/issues/17
      def broadcast_update
        broadcast broadcast_event_name(:updated), self, previous_changes
      end

      # broadcast MODEL_destroyed to subscribed listeners
      # pass a serialized version of the object attributes
      # for listeners since the object is no longer accessible in the database
      def broadcast_destroy
        broadcast broadcast_event_name(:destroyed), attributes
      end

      def broadcast_event_name(lifecycle)
        "#{self.class.model_name.param_key}_#{lifecycle}"
      end

      def should_broadcast?(event)
        (
          wisper_activerecord_publisher_broadcast_events ||
          Wisper::ActiveRecord::Publisher.configuration.default_broadcast_events
        ).include?(event)
      end
    end
  end
end

ActiveSupport.on_load(:active_record) do
  include Wisper::ActiveRecord::Publisher
end
