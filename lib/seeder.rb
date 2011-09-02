class Seeder

  class << self

    def existing_data_keys(ar_model)
      keys = @primary_keys[ar_model.name]
      ar_model.all.map{|item| item.attributes.symbolize_keys.values_at(*keys) }
    end

    def seed_data_keys(ar_model)
      keys = @primary_keys[ar_model.name]
      @data[ar_model.name].collect{|attributes| attributes.values_at(*keys) }
    end

    def items_to_delete(ar_model)
      existing_data_keys(ar_model) - seed_data_keys(ar_model)
    end

    def value_to_sql(value)
      if value.nil? then 'NULL'
      elsif value.is_a?(String) then "'#{value}'"
      elsif value == false then 0
      elsif value == true then 1
      else value
      end
    end

    def add_new_or_changed_data(ar_model)
      keys = @primary_keys[ar_model.name]
      find_method = "find_by_#{keys.join('_and_')}"
      @data[ar_model.name].collect do |attributes|
        relevant_keys = attributes.keys & ar_model.column_names.map(&:to_sym)
        existing = ar_model.send(find_method, *attributes.values_at(*keys))
        next if existing && attributes.values_at(*relevant_keys) == existing.attributes.symbolize_keys.values_at(*relevant_keys)
        values = attributes.values_at(*relevant_keys)
        %{
          INSERT INTO #{ar_model.table_name} (#{relevant_keys.map{|col| "`#{col}`"}.join(', ')}) VALUES (#{values.map{|val| value_to_sql(val)}.join(', ')}) ON DUPLICATE KEY UPDATE #{relevant_keys.map{|col| "`#{col}` = VALUES(`#{col}`)"}.join(', ')}
        }
      end.compact
    end

    def delete_outdated_data(ar_model)
      keys = @primary_keys[ar_model.name]
      items_to_delete(ar_model).collect do |field_to_delete|
        conditions = field_to_delete.to_enum.with_index.collect{|value, index| "#{keys[index]} = '#{value}'"}.join(' AND ')
        %{ DELETE FROM #{ar_model.table_name} WHERE #{conditions} }
      end.compact
    end

    def create(data, keys, models)
      @data, @primary_keys = data, keys
      models.each {|model|
        delete_outdated_data(model).each{|query| sql(query)}
        add_new_or_changed_data(model).each{|query| sql(query)}
      }
    end

    def sql(sql_command)
      ActiveRecord::Base.connection.execute(sql_command)
    end
  end
end
