module OrderedActiveRecord
  def self.included(base)
    base.class_eval do
      def self.acts_as_ordered(column, options = {})
        before_create do
          insert_ordered_position(column, options)
        end

        before_destroy do
          remove_ordered_position(column, options)
        end

        before_update do
          if self.send(:"#{column}_changed?")
            position = self.send(column)
            position_was = self.send(:"#{column}_was")

            # column changes from not nil to nil, which is like removing it
            if position.nil?
              remove_ordered_position(column, options)
            # column changes from nil to not nil, which is like inserting it
            elsif position_was.nil?
              insert_ordered_position(column, options)
            elsif position.present? && position_was.present?
              from = [position, position_was + 1].min
              to = [position, position_was - 1].max
              sign = (position < position_was) ? '+' : '-'
              scope_for(column, options).
              where(column => from.eql?(to) ? from : from..to).
              update_all("#{column} = #{column} #{sign} 1")
            end
          end
        end
      end

    private

      def insert_ordered_position(column, options)
        position = self.send(column)
        if position.present?
          scope_for(column, options).
          where(["#{column} >= :position", :position => position]).
          update_all("#{column} = #{column} + 1")
        end
      end

      def remove_ordered_position(column, options)
        position_was = self.send(:"#{column}_was")
        if position_was.present?
          scope_for(column, options).
          where(["#{column} >= :position", :position => position_was]).
          update_all("#{column} = #{column} - 1")
        end
      end

      def scope_for(name, options)
        Array.wrap(options[:scope]).inject(self.class.where("#{name} IS NOT NULL")) do |scope, column|
          scope.where(column => self.send(column))
        end
      end
    end
  end
end

ActiveSupport.on_load(:active_record) do
  include OrderedActiveRecord
end