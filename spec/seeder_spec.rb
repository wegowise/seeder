require 'spec_helper'

describe Seeder do
  before(:each) { Grade.delete_all }

  let(:seeder) do
    Seeder.new(
      [{ 'student_id' => 1, 'course_id' => 1, 'grade' => 90 },
       { 'student_id' => 1, 'course_id' => 2, 'grade' => 80 }],
      %w[student_id course_id],
      Grade
    )
  end

  describe '.create' do
    it 'should call create on a new instance' do
      seeder = double
      expect(Seeder).to receive(:new).with(:data, :keys, :model)
        .and_return(seeder)
      expect(seeder).to receive(:create)

      Seeder.create(:data, :keys, :model)
    end
  end

  describe '#new' do
    specify { expect(seeder.model).to eq Grade }
    specify { expect(seeder.keys).to eq [:student_id, :course_id] }
    specify do
      expect(seeder.data).to eq(
        [{ student_id: 1, course_id: 1, grade: 90 },
         { student_id: 1, course_id: 2, grade: 80 }]
      )
    end
  end

  describe '#delete_outdated_records' do
    before do
      Grade.create!(student_id: 1, course_id: 3)
      Grade.create!(student_id: 1, course_id: 1)
    end

    it 'should delete outdated records' do
      expect { seeder.delete_outdated_records }.to change { Grade.count }.to(1)
      expect(Grade.first.course_id).to eq 1
    end
  end

  describe '#update_existing_records' do
    let!(:existing_grade) { Grade.create!(student_id: 1, course_id: 1) }

    it 'should delete outdated records' do
      expect { seeder.update_existing_records }
        .to change { existing_grade.reload.grade }.to(90)
    end
  end

  describe '#create_new_records' do
    let!(:existing_grade) { Grade.create!(student_id: 1, course_id: 1) }

    it 'should create new records when there are no existing records with
    matching keys' do
      expect { seeder.create_new_records }.to change { Grade.count }.to(2)
      expect(Grade.last.course_id).to eq 2
    end
  end

  describe '#create' do
    it 'calls the delete, update and create methods in order' do
      expect(seeder).to receive(:delete_outdated_records).ordered
      expect(seeder).to receive(:update_existing_records).ordered
      expect(seeder).to receive(:create_new_records).ordered
      seeder.create
    end

    it 'aborts when an exception is raised' do
      allow(seeder)
        .to receive(:create_new_records)
        .and_raise(ActiveRecord::RecordInvalid.new(Grade.new))
      initial_attributes = Grade.all.map(&:attributes)

      expect { seeder.create }.to raise_error(ActiveRecord::RecordInvalid)

      expect(Grade.all.map(&:attributes)).to eq(initial_attributes)
    end

    it 'produces the appropriate results' do
      grade1 = Grade.create!(student_id: 1, course_id: 3)
      grade2 = Grade.create!(student_id: 1, course_id: 1)

      seeder.create

      expect(Grade.count).to eq(2)
      expect(Grade.exists?(grade1.id)).to eq(false)

      grade2.reload
      expect(grade2.student_id).to eq(1)
      expect(grade2.course_id).to eq(1)
      expect(grade2.grade).to eq(90)

      grade3 = Grade.last
      expect(grade3.student_id).to eq(1)
      expect(grade3.course_id).to eq(2)
      expect(grade3.grade).to eq(80)
    end
  end

end
