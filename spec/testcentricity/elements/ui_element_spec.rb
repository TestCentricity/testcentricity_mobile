# frozen_string_literal: true

describe TestCentricity::AppElements::AppUIElement, required: true do
  subject(:test_element) { described_class.new(:test_element, self, { accessibility_id: 'element 1' }, :screen) }

  it 'returns class' do
    expect(test_element.class).to eql described_class
  end

  it 'returns name' do
    expect(test_element.get_name).to eql :test_element
  end

  it 'returns locator' do
    expect(test_element.get_locator).to eql({ accessibility_id: 'element 1'})
  end

  it 'should click the element' do
    allow(test_element).to receive(:click)
    test_element.click
  end

  it 'should tap the element' do
    allow(test_element).to receive(:tap)
    test_element.tap
  end

  it 'should double tap the element' do
    allow(test_element).to receive(:double_tap)
    test_element.double_tap
  end

  it 'should long press the element' do
    allow(test_element).to receive(:long_press)
    test_element.long_press
  end

  it 'should know if element is visible' do
    allow(test_element).to receive(:visible?).and_return(false)
    expect(test_element.visible?).to eq(false)
  end

  it 'should know if element is hidden' do
    allow(test_element).to receive(:hidden?).and_return(true)
    expect(test_element.hidden?).to eq(true)
  end

  it 'should know if element exists' do
    allow(test_element).to receive(:exists?).and_return(true)
    expect(test_element.exists?).to be true
  end

  it 'should know if element is enabled' do
    allow(test_element).to receive(:enabled?).and_return(true)
    expect(test_element.enabled?).to eq(true)
  end

  it 'should know if element is disabled' do
    allow(test_element).to receive(:disabled?).and_return(true)
    expect(test_element.disabled?).to eq(true)
  end

  it 'should know if element is selected' do
    allow(test_element).to receive(:selected?).and_return(true)
    expect(test_element.selected?).to eq(true)
  end

  it 'returns value' do
    allow(test_element).to receive(:value).and_return('value')
    expect(test_element.value).to eql 'value'
  end

  it 'should send keys' do
    allow(test_element).to receive(:send_keys).with('foo bar')
    test_element.send_keys('foo bar')
  end
end
