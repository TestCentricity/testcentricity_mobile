# frozen_string_literal: true

describe TestCentricity::ScreenSection, required: true do
  before :context do
    @test_screen = TestScreen.new
    @test_section = @test_screen.section1
  end

  context 'section object traits' do
    it 'returns section name' do
      expect(@test_section.section_name).to eq('Basic Test Section')
    end

    it 'returns section locator' do
      expect(@test_section.get_locator).to eq([{ accessibility_id: 'test section' }])
    end

    it 'returns class' do
      expect(@test_section.class).to eql TestScreenSection
    end

    it 'registers with type section' do
      expect(@test_section.get_object_type).to eql :section
    end

    it 'responds to exists?' do
      expect(@test_section).to respond_to(:exists?)
    end

    it 'should click the element' do
      allow(@test_section).to receive(:click)
      @test_section.click
    end

    it 'should tap the element' do
      allow(@test_section).to receive(:tap)
      @test_section.tap
    end

    it 'should double tap the element' do
      allow(@test_section).to receive(:double_tap)
      @test_section.double_tap
    end

    it 'should long press the element' do
      allow(@test_section).to receive(:long_press)
      @test_section.long_press
    end

    it 'should know if element is visible' do
      allow(@test_section).to receive(:visible?).and_return(false)
      expect(@test_section.visible?).to eq(false)
    end

    it 'should know if element is hidden' do
      allow(@test_section).to receive(:hidden?).and_return(true)
      expect(@test_section.hidden?).to eq(true)
    end

    it 'should know if element exists' do
      allow(@test_section).to receive(:exists?).and_return(true)
      expect(@test_section.exists?).to be true
    end

    it 'should know if element is enabled' do
      allow(@test_section).to receive(:enabled?).and_return(true)
      expect(@test_section.enabled?).to eq(true)
    end

    it 'should know if element is disabled' do
      allow(@test_section).to receive(:disabled?).and_return(true)
      expect(@test_section.disabled?).to eq(true)
    end
  end

  context 'section object with UI elements' do
    it 'responds to element' do
      expect(@test_section).to respond_to(:element1)
    end

    it 'responds to button' do
      expect(@test_section).to respond_to(:button1)
    end

    it 'responds to textfield' do
      expect(@test_section).to respond_to(:field1)
    end

    it 'responds to image' do
      expect(@test_section).to respond_to(:image1)
    end

    it 'responds to switch' do
      expect(@test_section).to respond_to(:switch1)
    end

    it 'responds to checkbox' do
      expect(@test_section).to respond_to(:check1)
    end

    it 'responds to radio' do
      expect(@test_section).to respond_to(:radio1)
    end

    it 'responds to section' do
      expect(@test_section).to respond_to(:section2)
    end
  end
end
