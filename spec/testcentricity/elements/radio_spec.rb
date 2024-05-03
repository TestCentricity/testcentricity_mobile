# frozen_string_literal: true

describe TestCentricity::AppElements::AppRadio, required: true do
  subject(:test_radio) { described_class.new(:test_radio, self, { accessibility_id: 'radio 1' }, :screen) }

  it 'returns class' do
    expect(test_radio.class).to eql TestCentricity::AppElements::AppRadio
  end

  it 'registers with type radio' do
    expect(test_radio.get_object_type).to eql :radio
  end

  it 'should select the radio' do
    expect(test_radio).to receive(:select)
    test_radio.select
  end

  it 'should unselect the radio' do
    expect(test_radio).to receive(:unselect)
    test_radio.unselect
  end

  it 'should know if radio is selected' do
    allow(test_radio).to receive(:selected?).and_return(true)
    expect(test_radio.selected?).to eq(true)
  end
end
