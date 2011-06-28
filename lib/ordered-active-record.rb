require 'active_record'

module OrderedActiveRecord
  VERSION = '0.4.0'

  def self.included(base)
    base.class_eval do
      cattr_accessor :ordered_columns

      def self.acts_as_ordered(column, options = {})
        # add ordering hooks when first column is added
        if self.ordered_columns.nil?
          self.ordered_columns = []
          [:create, :destroy, :update].each do |hook|
            self.send(:"before_#{hook}") do
              self.class.ordered_columns.all? do |column|
                column.send(hook, self)
              end
            end
          end
        end

        self.ordered_columns << Column.new(self, column, options)
      end
    end
  end

  class Column
    def initialize(klass, name, options = {})
      @name = name.to_sym
      @quoted_name = klass.connection.quote_column_name(@name)
      @options = options
      @arel = klass.arel_table
    end

    def create(instance)
      value = instance.send(@name)
      if value.present?
        scope_for(instance).
          where(@arel[@name].gteq(value)).
          update_all("#{@quoted_name} = #{@quoted_name} + 1")
      end
      true
    end

    def destroy(instance)
      value_was = instance.send(:"#{@name}_was")
      if value_was.present?
        scope_for(instance).
          where(@arel[@name].gt(value_was)).
          update_all("#{@quoted_name} = #{@quoted_name} - 1")
      end
      true
    end

    def update(instance)
      if instance.send(:"#{@name}_changed?")
        value = instance.send(@name)
        value_was = instance.send(:"#{@name}_was")

        # column changes from not nil to nil, which is like deleting it
        if value.nil?
          destroy(instance)
        # column changes from nil to not nil, which is like creating it
        elsif value_was.nil?
          create(instance)
        elsif value.present? && value_was.present?
          from = [value, value_was + 1].min
          to = [value, value_was - 1].max
          sign = (value < value_was) ? '+' : '-'
          scope_for(instance).
            where(@arel[:id].not_eq(instance.id)).
            where(@name => from.eql?(to) ? from : from..to).
            update_all("#{@quoted_name} = #{@quoted_name} #{sign} 1")
        end
      end
      true
    end

  private

    def scope_for(instance)
      scope = instance.class.where(@arel[@name].not_eq(nil))
      Array.wrap(@options[:scope]).inject(scope) do |scope, scope_column|
        scope.where(@arel[scope_column].eq(instance.send(scope_column)))
      end
    end
  end
end

ActiveRecord::Base.send(:include, OrderedActiveRecord)