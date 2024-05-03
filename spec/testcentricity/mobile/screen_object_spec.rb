# frozen_string_literal: true

describe TestCentricity::ScreenObject, required: true do
  before :context do
    @test_screen = TestScreen.new
  end

  context 'screen object traits' do
    it 'returns screen name' do
      expect(@test_screen.screen_name).to eq('Basic Test Screen')
    end

    it 'returns screen locator' do
      expect(@test_screen.screen_locator).to eq({ accessibility_id: 'test screen' })
    end

    it 'responds to load_screen' do
      expect(@test_screen).to respond_to(:load_screen)
    end

    it 'responds to verify_screen_exists' do
      expect(@test_screen).to respond_to(:verify_screen_exists)
    end

    it 'responds to exists?' do
      expect(@test_screen).to respond_to(:exists?)
    end
  end

  context 'screen object with UI elements' do
    it 'responds to element' do
      expect(@test_screen).to respond_to(:element1)
    end

    it 'responds to button' do
      expect(@test_screen).to respond_to(:button1)
    end

    it 'responds to textfield' do
      expect(@test_screen).to respond_to(:field1)
    end

    it 'responds to image' do
      expect(@test_screen).to respond_to(:image1)
    end

    it 'responds to switch' do
      expect(@test_screen).to respond_to(:switch1)
    end

    it 'responds to checkbox' do
      expect(@test_screen).to respond_to(:check1)
    end

    it 'responds to radio' do
      expect(@test_screen).to respond_to(:radio1)
    end

    it 'responds to section' do
      expect(@test_screen).to respond_to(:section1)
    end
  end
end
