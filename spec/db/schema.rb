# setup in-memory database
# see http://stackoverflow.com/questions/10605053/testing-activerecord-models-inside-a-gem
ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
ActiveRecord::Schema.define do
  self.verbose = false

  create_table :users, force: true do |t|
    t.string :name
  end
end
