require 'spec_helper'

describe Fars::BaseModelSerializer do
  before :each do
    @object = Master.create(id: 1, name: 'Object1', data: '123')
    1.upto(2) { |i| Slave.create(id: i, master_id: @object.id, name: "Slave #{i}") }
  end

  context 'without API version' do
    context '#to_json' do
      it 'returns all fields with metadata' do
        json_data = {
          master: { id: 1, name: 'Object1', data: '123' },
          _metadata: { metadata: :present }
        }.to_json

        MasterSerializer.new(@object,
          add_metadata: true,
          fields: [:id, :name, :data]
        ).to_json.should == json_data
      end

      it 'returns not all field, whithout metadata' do
        json_data = { master: { id: 1, name: 'Object1' } }.to_json

        MasterSerializer.new(@object,
          add_metadata: false,
          fields: [:id, :name]
        ).to_json.should == json_data
      end

      it 'returns not all field, whithout metadata if serializer does not respond to meta method' do
        json_data = { master: { id: 1, name: 'Object1' } }.to_json

        MasterSerializer.any_instance.stub(:respond_to?).with(:meta).and_return(false)

        MasterSerializer.new(@object,
          fields: [:id, :name]
        ).to_json.should == json_data
      end

      it 'returns all field with slaves' do
        json_data = { master: { id: 1, name: 'Object1', data: '123',
          slaves: [
            { slave: { id: 1, name: 'Slave 1', data: nil } },
            { slave: { id: 2, name: 'Slave 2', data: nil } },
          ]}}.to_json

        MasterSerializer.new(@object,
          add_metadata: false,
          fields: [:id, :name, :data, :slaves]
        ).to_json.should == json_data
      end

      it 'returns all field with slaves' do
        json_data = { master: { id: 1, name: 'Object1', data: '123',
          slaves: [
            { slave: { id: 1, name: 'Slave 1', data: nil } },
            { slave: { id: 2, name: 'Slave 2', data: nil } },
          ]}}.to_json

        @object.serialize(
          add_metadata: false,
          fields: [:id, :name, :data, :slaves]
        ).should == json_data
      end
    end
  end

  context 'with API version' do
    context '#to_json' do
      it 'returns all fields with metadata' do
        json_data = {
          master: { id: 1, name: 'Object1', data: '123' },
          _metadata: { metadata: :present }
        }.to_json

        V1::MasterSerializer.new(@object,
          add_metadata: true,
          fields: [:id, :name, :data],
          api_version: 'V1'
        ).to_json.should == json_data
      end

      it 'returns not all field, whithout metadata' do
        json_data = { master: { id: 1, name: 'Object1' } }.to_json

        V1::MasterSerializer.new(@object,
          add_metadata: false,
          fields: [:id, :name],
          api_version: 'V1'
        ).to_json.should == json_data
      end

      it 'returns all field with slaves' do
        json_data = { master: { id: 1, name: 'Object1', data: '123',
          slaves: [
            { slave: { id: 1, name: 'Slave 1', data: nil, updated_at: '2014-04-14' } },
            { slave: { id: 2, name: 'Slave 2', data: nil, updated_at: '2014-04-14' } },
          ]}}.to_json

        V1::MasterSerializer.new(@object,
          add_metadata: false,
          fields: [:id, :name, :data, :slaves],
          api_version: 'V1'
        ).to_json.should == json_data
      end
    end
  end
end
