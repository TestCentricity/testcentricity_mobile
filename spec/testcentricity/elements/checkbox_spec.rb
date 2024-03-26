# frozen_string_literal: true

describe TestCentricity::AppElements::AppCheckBox, required: true do
  subject(:test_check) { described_class.new(:test_check, self, { accessibility_id: 'check 1' }, :screen) }

  it 'returns class' do
    expect(test_check.class).to eql TestCentricity::AppElements::AppCheckBox
  end

  it 'registers with type checkbox' do
    expect(test_check.get_object_type).to eql :checkbox
  end

  it 'should check the checkbox' do
    expect(test_check).to receive(:check)
    test_check.check
  end

  it 'should uncheck the checkbox' do
    expect(test_check).to receive(:uncheck)
    test_check.uncheck
  end

  it 'should know if checkbox is checked' do
    allow(test_check).to receive(:checked?).and_return(true)
    expect(test_check.checked?).to eq(true)
  end
end
