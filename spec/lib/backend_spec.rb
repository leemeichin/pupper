require 'spec_helper'

RSpec.describe Pupper::Backend do
  subject { FakeBackend.new }

  it 'should have a default User Agent header' do
    expect(subject.headers).to include('User-Agent' => Pupper.config.user_agent)
  end

  it 'should have an authorization token' do
    expect(subject.headers).to have_key('Authorization')
  end

  it 'should have a base URL' do
    expect(subject.base_url).to eq('https://example.com/')
  end
end
