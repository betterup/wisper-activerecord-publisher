require 'spec_helper'

describe Wisper::Activerecord::Publisher do
  class User < ActiveRecord::Base
  end

  before do
    User.broadcast_on *Wisper::ActiveRecord::Publisher.configuration.default_broadcast_events
  end

  describe '#broadcast_create' do
    it 'broadcasts event' do
      user = User.new(name: 'Foo Bar')
      expect(user).to receive(:broadcast).with('user_created', user)
      user.save!
    end
  end

  describe '#broadcast_update' do
    it 'broadcasts event' do
      user = User.create!(name: 'Foo Bar')
      expect(user).to receive(:broadcast).with('user_updated', user, name: ['Foo Bar', 'Foo Bar Baz'])
      user.update!(name: 'Foo Bar Baz')
    end
  end

  describe '#broadcast_destroy' do
    it 'broadcasts event' do
      user = User.create!(name: 'Foo Bar')
      expect(user).to receive(:broadcast).with('user_destroyed', 'id' => user.id, 'name' => 'Foo Bar')
      user.destroy
    end
  end

  context 'when specific broadcasts are specified' do
    before do
      User.broadcast_on :create
    end

    describe '#broadcast_create' do
      it 'broadcasts event' do
        user = User.new(name: 'Foo Bar')
        expect(user).to receive(:broadcast).with('user_created', user)
        user.save!
      end
    end

    describe '#broadcast_update' do
      it 'does not broadcast the event' do
        user = User.create!(name: 'Foo Bar')
        expect(user).not_to receive(:broadcast)
        user.update!(name: 'Foo Bar Baz')
      end
    end

    describe '#broadcast_destroy' do
      it 'does not broadcast the event' do
        user = User.create!(name: 'Foo Bar')
        expect(user).not_to receive(:broadcast)
        user.destroy
      end
    end
  end

  context 'when an unknown broadcast event is specified' do
    it 'raises an ArgumentError' do
      expect { User.broadcast_on :yolo }.to raise_error(ArgumentError)
    end
  end

  context 'when no broadcasts are specified' do
    before { User.broadcast_on :none }

    it 'never broadcasts events' do
      user = User.new(name: 'Foo Bar')

      expect(user).not_to receive(:broadcast)

      user.save!
      user.update!(name: 'Foo Bar Baz')
      user.destroy
    end
  end

  context 'when no broadcasts are specified' do
    before { User.wisper_activerecord_publisher_broadcast_events = nil }

    it 'defaults to the configuration which includes all events' do
      user = User.new(name: 'Foo Bar')

      expect(user).to receive(:broadcast).with('user_created', user)
      expect(user).to receive(:broadcast).with('user_updated', any_args)
      expect(user).to receive(:broadcast).with('user_destroyed', any_args)

      user.save!
      user.update!(name: 'Foo Bar Baz')
      user.destroy
    end
  end
end
