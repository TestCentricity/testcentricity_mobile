# frozen_string_literal: true

describe TestCentricity::AppElements::AppTextField, required: true do
  subject(:test_text_field) { described_class.new(:test_text_field, self, { accessibility_id: 'textfield 1' }, :screen) }

  it 'returns class' do
    expect(test_text_field.class).to eql TestCentricity::AppElements::AppTextField
  end

  it 'registers with type textfield' do
    expect(test_text_field.get_object_type).to eql :textfield
  end
end
