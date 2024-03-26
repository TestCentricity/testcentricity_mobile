# frozen_string_literal: true

describe TestCentricity::AppElements::AppLabel, required: true do
  subject(:test_label) { described_class.new(:test_label, self, { accessibility_id: 'label 1' }, :screen) }

  it 'returns class' do
    expect(test_label.class).to eql TestCentricity::AppElements::AppLabel
  end

  it 'registers with type label' do
    expect(test_label.get_object_type).to eql :label
  end

  it 'returns caption' do
    allow(test_label).to receive(:caption).and_return('caption')
    expect(test_label.caption).to eql 'caption'
  end
end
