require "active_record"
require "seeder"

ActiveRecord::Base.establish_connection(
  adapter: "mysql2",
  database: ENV.fetch("DB_NAME", "polymorpheus_test"),
  host: ENV.fetch("DB_HOST", "127.0.0.1"),
  password: ENV.fetch("DB_PASSWORD", ""),
  port: ENV.fetch("DB_PORT", "3306"),
  username: ENV.fetch("DB_USERNAME", "root")
)

RSpec.configure do |config|
  config.before(:suite) do
    ActiveRecord::Schema.define do
      create_table :grades do |t|
        t.integer :student_id
        t.integer :course_id
        t.integer :grade
      end
    end
  end

  config.after(:suite) do
    ActiveRecord::Base.connection.tables.each do |table|
      ActiveRecord::Base.connection.drop_table table
    end
  end
end

class Grade < ActiveRecord::Base
end
