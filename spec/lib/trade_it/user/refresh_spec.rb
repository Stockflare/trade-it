require 'spec_helper'

describe TradeIt::User::Refresh do
  let(:username) { "dummy" }
  let(:password) { "pass" }
  let(:broker) { :dummy }
  let!(:user) do
    TradeIt::User::LinkAndLogin.new(
      username: username,
      password: password,
      broker: broker
    ).call.response.payload
  end
  let(:token) { user[:token] }

  subject do
    TradeIt::User::Refresh.new(
      token: token
    ).call.response
  end

  describe 'good logout' do
    it 'returns token' do
      expect(subject.status).to eql 200
      expect(subject.payload[:type]).to eql 'success'
      expect(subject.payload[:token]).not_to be_empty
      expect(subject.payload[:token]).to eql token
    end
  end


  describe 'bad token' do
    let(:token) { 'foooooobaaarrrr' }
    it 'throws error' do
      expect{subject}.to raise_error(TradeIt::Errors::LoginException)
    end
  end

end
