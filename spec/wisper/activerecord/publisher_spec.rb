require 'spec_helper'

describe Wisper::Activerecord::Publisher do
  class User < ActiveRecord::Base
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
end
