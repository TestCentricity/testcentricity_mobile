# frozen_string_literal: true

describe TestCentricity::AppElements::AppImage, required: true do
  subject(:test_image) { described_class.new(:test_image, self, { accessibility_id: 'image 1' }, :screen) }

  it 'returns class' do
    expect(test_image.class).to eql TestCentricity::AppElements::AppImage
  end

  it 'registers with type image' do
    expect(test_image.get_object_type).to eql :image
  end
end
