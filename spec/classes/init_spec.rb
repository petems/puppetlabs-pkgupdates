require 'spec_helper'
describe 'pkgupdates' do

  context 'with defaults for all parameters' do
    it { should contain_class('pkgupdates') }
  end
end
