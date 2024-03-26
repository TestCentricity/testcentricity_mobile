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

    it 'responds to section' do
      expect(@test_section).to respond_to(:section2)
    end
  end
end
