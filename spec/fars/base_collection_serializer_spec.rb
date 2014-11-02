require 'spec_helper'

describe Fars::BaseCollectionSerializer do
  before(:each) do
    1.upto(2) { |i| Master.create(id: i, name: "Object#{i}", data: '123') }
    1.upto(3) { |i| Slave.create(id: i, master_id: (i % 2) + 1, name: "Slave #{i}") }
  end

  context 'without API version' do
    context '#to_json' do
      it 'returns all fields with metadata' do
        json_data = { masters: [
          { master: { id: 1, name: 'Object1' }, _metadata: { metadata: :present } },
          { master: { id: 2, name: 'Object2' }, _metadata: { metadata: :present } }
        ] }.to_json

        described_class.new(Master.where('1 = 1'),
          add_metadata: true,
          fields: [:id, :name]
        ).to_json.should == json_data
      end      
    end
  end

  context 'with API version' do
    context '#to_json' do
      it 'returns all fields and relations withot metadata' do
        json_data = { masters: [
          { master: { id: 1, name: 'Object1', data: '123', updated_at: '2014-04-14',
                      slaves: [{ slave: { id: 2, name: 'Slave 2', data: nil, updated_at: '2014-04-14' } }] } },
          { master: { id: 2, name: 'Object2', data: '123', updated_at: '2014-04-14',
                      slaves: [
                        { slave: { id: 1, name: 'Slave 1', data: nil, updated_at: '2014-04-14'} },
                        { slave: { id: 3, name: 'Slave 3', data: nil, updated_at: '2014-04-14'} }
                      ] } }
          ] }.to_json

        described_class.new(Master.where('1 = 1'),
          add_metadata: false,
          api_version: 'V1'
        ).to_json.should == json_data
      end

      it 'filtered by available_attributes for each object of collection' do
        Master.create(id: 3, name: "NO DATA", data: 'secret data')
        json_data = { masters: [
          { master: { id: 1, name: 'Object1', data: '123', updated_at: '2014-04-14',
                      slaves: [{ slave: { id: 2, name: 'Slave 2', data: nil, updated_at: '2014-04-14' } }] } },
          { master: { id: 2, name: 'Object2', data: '123', updated_at: '2014-04-14',
                      slaves: [
                        { slave: { id: 1, name: 'Slave 1', data: nil, updated_at: '2014-04-14'} },
                        { slave: { id: 3, name: 'Slave 3', data: nil, updated_at: '2014-04-14'} }
                      ] } },
          { master: { id: 3, name: 'NO DATA', updated_at: '2014-04-14',
                      slaves: [] } }
          ] }.to_json

        described_class.new(Master.where('1 = 1'),
          add_metadata: false,
          api_version: 'V1'
        ).to_json.should == json_data
      end      
    end
  end
end
