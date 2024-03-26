# frozen_string_literal: true

describe TestCentricity::AppElements::AppButton, required: true do
  subject(:test_button) { described_class.new(:test_button, self, { accessibility_id: 'button 1' }, :screen) }

  it 'returns class' do
    expect(test_button.class).to eql TestCentricity::AppElements::AppButton
  end

  it 'registers with type button' do
    expect(test_button.get_object_type).to eql :button
  end

  it 'should click the button' do
    expect(test_button).to receive(:click)
    test_button.click
  end
end
