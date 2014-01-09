# Ordered Active Record (for ActiveRecord 3 or higher)

This gem allows you to have ordered models. It is like the old *acts_as_list*
gem, but very lightweight and with an optimized SQL syntax.

Suppose you want to order a Post model by position. You need to add a
`position` column to the table *posts* first.

    class CreatePost < ActiveRecord::Migration
      def change
        create_table(:posts) do |t|
          ...
          t.integer(:position, null: false)
        end
      end
    end

You can make the `position` column optional: only records with entered
positions will be ordered. In rare cases, you can also add extra order columns.

To add ordering to a model, do the following:

    class Post < ActiveRecord::Base
      acts_as_ordered(:position)
    end

You can also order within the scope of other columns, which is useful for
things like associations:

    class Detail < ActiveRecord::Base
      belongs_to(:post)
      acts_as_ordered(:position, scope: :post_id)
    end

This means the order positions are unique within the scope of `post_id`.

# Examples

Check out the tests (in `spec/lib/ordered-active-record.rb`) to see more
examples.

Suppose you have these records (for all examples this is the starting point):

    id | position
    ---+---------
     1 |        1
     2 |        2
     3 |        3

## Insert a new record at position 2

The existing records with position greater than or equal to 2 will have their
position increased by 1 and the new record (with id 4) is inserted:

    Post.create(position: 2)

    id | position
    ---+---------
     1 |        1
     2 |        3 # moved down
     3 |        4 # moved down
     4 |        2 # inserted

## Delete a record at position 2

The existing records with position greater than or equal to 2 will have their
position decreased by 1 and the record (with id 2) is deleted:

    Post.find(2).destroy

    id | position
    ---+---------
     1 |        1
                  # deleted
     3 |        2 # moved up

## Move a record down from position 1 to position 2

The existing record with position equal to 2 will have its position decreased
by 1 and the record (with id 1) is moved down:

    Post.find(1).update_attributes(position: 2)

    id | position
    ---+---------
     1 |        2 # moved down
     2 |        1 # moved up
     3 |        3

## Move a record up from position 3 to position 1

The existing records with position greater than or equal to 1 and less than or
equal to 2 will have their position increased by 1 and the record (with id 3)
is moved up:

    Post.find(3).update_attributes(position: 1)

    id | position
    ---+---------
     1 |        2 # moved down
     2 |        3 # moved down
     3 |        1 # moved up

## Insert a new record at position 5

This will create a gap in the positions and is bad behavior. It is the task of
the developer to avoid this situation. The gem doesn't check the highest
existing position (to avoid execution of an extra query).

    Post.create(position: 5)

    id | position
    ---+---------
     1 |        1
     2 |        2
     3 |        3
                  # gap
     4 |        5 # inserted

## Insert a new record with an empty position

This will not affect the other records.

    Post.create(position: nil)

    id | position
    ---+---------
     1 |        1
     2 |        2
     3 |        3
     4 |      nil # inserted, but without position

## Clear a record's position

Clearing a record's position, is like deleting its position.

    Post.find(1).update_attributes(position: nil)

    id | position
    ---+---------
     1 |      nil
     2 |        1 # moved up
     3 |        2 # moved up

# Copyright

&copy; 2011-2014 Walter Horstman, [IT on Rails](http://itonrails.com)