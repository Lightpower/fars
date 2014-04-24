require 'spec_helper'

describe 'Hash#serialize' do
  subject do
    { '2014-01' => { visitors: 23, visits: 114 }, '2014-02' => { visitors: 27, visits: 217 } }
  end

  specify 'with proc as item serializer' do
    json_data = { stats: [{ month: '2014-01', visitors: 23 }, { month: '2014-02', visitors: 27 }] }.to_json

    subject.serialize(root_key: :stats,
      serializer: Proc.new { |k, v| { month: k, visitors: v[:visitors] } }).should == json_data
  end

  specify 'with block as item serializer' do
    json_data = { stats: [{ month: '2014-01', visitors: 23 }, { month: '2014-02', visitors: 27 }] }.to_json

    subject.serialize(root_key: :stats) do |k, v|
      { month: k, visitors: v[:visitors] }
    end.should == json_data
  end

  specify 'custom class as item serializer' do
    json_data = { stats: [{ stat_key: '2014-01', stat_value: { visitors: 23, visits: 114 } },
              { stat_key: '2014-02', stat_value: { visitors: 27, visits: 217 } }] }.to_json

    subject.serialize(root_key: :stats, serializer: 'StatSerializer').should == json_data
  end

  specify 'with custom class as item serializer and without root_key' do
    json_data = [{ stat_key: '2014-01', stat_value: { visitors: 23, visits: 114 } },
              { stat_key: '2014-02', stat_value: { visitors: 27, visits: 217 } }].to_json

    subject.serialize(root_key: false, serializer: 'StatSerializer').should == json_data
  end
end
