require 'support/active_record/connection_adapters/abstract_mysql_adapter'

ActiveRecord::Base.establish_connection({
  adapter: 'mysql2',
  username: 'travis',
  database: 'seeder_test'
})

ActiveRecord::Base.connection.tables.each do |table|
  ActiveRecord::Base.connection.drop_table table
end

ActiveRecord::Schema.define do
  create_table :grades do |t|
    t.integer :student_id
    t.integer :course_id
    t.integer :grade
  end
end

class Grade < ActiveRecord::Base
end
