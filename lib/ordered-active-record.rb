module OrderedActiveRecord
  def self.included(base)
    base.class_eval do
      def self.acts_as_ordered(column, options = {})
        before_create do
          reorder_positions(column, :insert, options)
        end

        before_destroy do
          reorder_positions(column, :remove, options)
        end

        before_update do
          if self.send(:"#{column}_changed?")
            position_was, position = self.send("#{column}_change")

            if position.nil?
              reorder_positions(column, :remove, options)
            elsif position_was.nil?
              reorder_positions(column, :insert, options)
            else
              from = [position, position_was + 1].min
              to = [position, position_was - 1].max
              sign = (position < position_was) ? '+' : '-'
              scope_for(column, options).where(column => from.eql?(to) ? from : from..to).update_all("#{column} = #{column} #{sign} 1")
            end
          end
        end
      end

    private

      def reorder_positions(column, action, options)
        position = self.send(:insert.eql?(action) ? column : :"#{column}_was")
        if position.present?
          sign = :insert.eql?(action) ? '+' : '-'
          scope_for(column, options).where(["#{column} >= :position", :position => position]).update_all("#{column} = #{column} #{sign} 1")
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