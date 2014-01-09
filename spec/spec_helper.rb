require('active_record')
require('ordered-active-record')

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: File.dirname(__FILE__) + '/test.sqlite3')

# create "posts" table
ActiveRecord::Schema.define do
  create_table(:posts, force: true) do |t|
    t.string(:text, null: false)
    t.integer(:position)
    t.integer(:author_id)
  end
end

# create "animals" table
ActiveRecord::Schema.define do
  create_table(:animals, force: true) do |t|
    t.string(:type, null: false)
    t.string(:sound, null: false)
    t.integer(:ordering)
  end
end