# frozen_string_literal: true

describe TestCentricity::AppElements::AppList, required: true do
  subject(:test_list) { described_class.new(:test_list, self, { accessibility_id: 'list 1' }, :screen) }

  it 'returns class' do
    expect(test_list.class).to eql TestCentricity::AppElements::AppList
  end

  it 'registers with type list' do
    expect(test_list.get_object_type).to eql :list
  end
end
