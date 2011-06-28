require 'ordered-active-record'

ActiveRecord::Base.establish_connection(:adapter  => 'sqlite3',
                                        :database => File.dirname(__FILE__) + '/test.sqlite3')

# create "posts" table
ActiveRecord::Schema.define do
  create_table :posts, :force => true do |t|
    t.string  :text,     :null => false
    t.integer :position, :null => false
  end
end

# create "Post" model
class Post < ActiveRecord::Base
  acts_as_ordered :position
end