class Seeder

  class << self
    QUOTING = {
      "ActiveRecord::ConnectionAdapters::MysqlAdapter"  => "`",
      "ActiveRecord::ConnectionAdapters::Mysql2Adapter" => "`"
    }

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

    def quote(value)
      q = QUOTING[ActiveRecord::Base.connection.class.to_s] || '"'
      "#{q}#{value}#{q}"
    end

    def add_new_or_changed_data(ar_model)
      keys = @primary_keys[ar_model.name]
      find_method = "find_by_#{keys.join('_and_')}"

      @data[ar_model.name].collect do |attributes|
        relevant_keys = attributes.keys & ar_model.column_names.map(&:to_sym)
        existing = ar_model.send(find_method, *attributes.values_at(*keys))
        values = attributes.values_at(*relevant_keys)

        if existing
          updates    = attributes.slice(*relevant_keys).map { |k,v| "#{quote(k)} = #{value_to_sql(v)}" }.join(", ")
          conditions = keys.map { |k| "#{quote(k)} = #{value_to_sql(existing.send(k))}" }.join(" AND ")
          %(UPDATE #{ar_model.table_name} SET #{updates} WHERE #{conditions})
        else
          columns = relevant_keys.join(", ")
          inserts = attributes.slice(*relevant_keys).values.map { |v| value_to_sql(v) }.join(", ")
          %(INSERT INTO #{ar_model.table_name} (#{columns}) VALUES (#{inserts}))
        end
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
