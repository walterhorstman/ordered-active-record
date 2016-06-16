module OrderedActiveRecord
  def self.included(base)
    base.class_eval do
      def self.acts_as_ordered(column = :position, options = {})
        before_create do
          reorder_positions(column, send(column), true, options)
        end

        before_destroy do
          reorder_positions(column, send("#{column}_was"), false, options)
        end

        before_update do
          return unless send(:"#{column}_changed?")

          position_old, position_new = send("#{column}_change")
          if position_new.nil?
            reorder_positions(column, send("#{column}_was"), false, options)
          elsif position_old.nil?
            reorder_positions(column, send(column), true, options)
          else
            from = [position_new, position_old + 1].min
            to = [position_new, position_old - 1].max
            scope_for(column, options)
              .where(column => from.eql?(to) ? from : from..to)
              .update_all("#{column} = #{column} #{(position_new < position_old) ? '+' : '-'} 1")
          end
        end
      end

      private

      def reorder_positions(column, position, inserting, options)
        if position.present?
          scope_for(column, options)
            .where(["#{column} >= ?", position])
            .update_all("#{column} = #{column} #{inserting ? '+' : '-'} 1")
        end
      end

      def scope_for(column, options)
        Array.wrap(options[:scope]).reduce(self.class.base_class.where.not(column => nil)) do |scope, scope_column|
          scope.where(scope_column => send(scope_column))
        end
      end
    end
  end
end

ActiveSupport.on_load(:active_record) do
  include OrderedActiveRecord
end
