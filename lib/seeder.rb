class Seeder
  attr_reader :keys, :data, :model

  def self.create(data, keys, model)
    new(data, keys, model).create
  end

  def initialize(data, keys, model)
    @keys = keys.map(&:to_sym)
    @data = data.map(&:symbolize_keys)
    @model = model
  end

  def create
    model.transaction do
      delete_outdated_records
      update_existing_records
      create_new_records
    end
  end

  def delete_outdated_records
    return unless records_to_delete.present?
    model.where(id: records_to_delete).delete_all
  end

  def update_existing_records
    existing_records_keys_hash.each do |record_keys, record|
      attributes = data_keys_hash[record_keys]
      next unless attributes

      record.attributes = attributes
      record.save! if record.changed?
    end
  end

  def create_new_records
    new_keys = data_keys_hash.keys - existing_records_keys_hash.keys

    data_keys_hash.values_at(*new_keys).each do |attributes|
      model.create!(attributes)
    end
  end

  private

  def data_keys_hash
    @data_keys_hash ||= data.inject({}) do |hash, attributes|
      hash.merge!(attributes.values_at(*keys) => attributes)
    end
  end

  def existing_records_keys_hash
    @existing_records_keys_hash ||= model.all.inject({}) do |hash, record|
      record_keys = keys.map { |key| record.public_send(key) }
      hash.merge!(record_keys => record)
    end
  end

  def records_to_delete
    @records_to_delete ||= begin
      keys_to_delete = existing_records_keys_hash.keys - data_keys_hash.keys
      existing_records_keys_hash.values_at(*keys_to_delete)
    end
  end
end
