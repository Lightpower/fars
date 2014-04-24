require 'spec_helper'

describe 'ActiveRecord::Relation#serialize' do
  before(:each) do
    1.upto(2) { |i| Master.create(id: i, name: "Object#{i}", data: '123') }
    1.upto(3) { |i| Slave.create(id: i, master_id: (i % 2) + 1, name: "Slave #{i}") }
  end
  subject { Master.where('1 = 1').order(:id) }

  specify 'add metadata for collection' do
    json_data = { masters: [{ master: { name: 'Object1' } }, { master: { name: 'Object2' } }],
      _metadata: { order: :id } }.to_json

    subject.serialize(fields: :name, add_metadata: false, metadata: { order: :id }).should == json_data
  end
end
