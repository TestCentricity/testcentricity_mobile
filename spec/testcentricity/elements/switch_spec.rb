# frozen_string_literal: true

describe TestCentricity::AppElements::AppSwitch, required: true do
  subject(:test_switch) { described_class.new(:test_switch, self, { accessibility_id: 'switch 1' }, :screen) }

  it 'returns class' do
    expect(test_switch.class).to eql TestCentricity::AppElements::AppSwitch
  end

  it 'registers with type switch' do
    expect(test_switch.get_object_type).to eql :switch
  end

  it 'should set the switch to on' do
    expect(test_switch).to receive(:on)
    test_switch.on
  end

  it 'should set the switch to off' do
    expect(test_switch).to receive(:off)
    test_switch.off
  end

  it 'should know if switch is on' do
    allow(test_switch).to receive(:on?).and_return(true)
    expect(test_switch.on?).to eq(true)
  end
end
