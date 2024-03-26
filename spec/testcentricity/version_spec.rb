# frozen_string_literal: true

describe 'TestCentricityMobile::VERSION', required: true do
  subject { TestCentricityMobile::VERSION }

  it { is_expected.to be_truthy }
end