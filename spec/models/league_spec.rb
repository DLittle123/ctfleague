require 'spec_helper'

describe League do
  it { should belong_to :commissioner }
  it { should have_many :teams }
  it { should validate_presence_of :commissioner }
  it { should validate_uniqueness_of :name }
end
