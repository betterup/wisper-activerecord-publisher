require 'wisper/activerecord/publisher/version'
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

        ActiveSupport::Deprecation.silence do
          after_commit :broadcast_create, on: :create
          after_commit :broadcast_update, on: :update
          after_commit :broadcast_destroy, on: :destroy
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
    end
  end
end
ActiveSupport.on_load(:active_record) do
  include Wisper::ActiveRecord::Publisher
end
