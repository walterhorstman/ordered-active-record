module OrderedActiveRecord
  def self.included(base)
    base.class_eval do
      def self.acts_as_ordered(column, options = {})
        before_create do
          reorder_positions(column, self.send(column), :insert, options)
        end

        before_destroy do
          reorder_positions(column, self.send("#{column}_was"), :remove, options)
        end

        before_update do
          if self.send(:"#{column}_changed?")
            position_old, position_new = self.send("#{column}_change")

            if position_new.nil?
              reorder_positions(column, self.send("#{column}_was"), :remove, options)
            elsif position_old.nil?
              reorder_positions(column, self.send(column), :insert, options)
            else
              from = [position_new, position_old + 1].min
              to = [position_new, position_old - 1].max
              scope_for(column, options).where(column => from.eql?(to) ? from : from..to).update_all("#{column} = #{column} #{(position_new < position_old) ? '+' : '-'} 1")
            end
          end
        end
      end

    private

      def reorder_positions(column, position, action, options)
        if position.present?
          scope_for(column, options).where(["#{column} >= ?", position]).update_all("#{column} = #{column} #{:insert.eql?(action) ? '+' : '-'} 1")
        end
      end

      def scope_for(name, options)
        Array.wrap(self.send :scope_symbol || options[:scope]).inject(self.class.base_class.where("#{name} IS NOT NULL")) do |scope, column|
          scope.where(column => self.send(column))
        end
      end
    end
  end
end

ActiveSupport.on_load(:active_record) do
  include OrderedActiveRecord
end
