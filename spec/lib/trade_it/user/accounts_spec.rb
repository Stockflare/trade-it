require 'spec_helper'

describe TradeIt::User::Account do
  let(:username) { 'dummy' }
  let(:password) { 'pass' }
  let(:broker) { :dummy }
  let(:answer) { 'tradingticket' }
  let!(:user) do
    TradeIt::User::LinkAndLogin.new(
      username: username,
      password: password,
      broker: broker
    ).call.response.payload
  end
  let(:token) { user.token }
  let(:account_number) { user.accounts[0].account_number }

  describe 'Get Account' do
    subject do
      TradeIt::User::Account.new(
        token: token,
        account_number: account_number
      ).call.response
    end
    it 'returns details' do
      expect(subject.status).to eql 200
      expect(subject.payload.cash).to be > 0
      expect(subject.payload.token).not_to be_empty
      expect(subject.payload.power).to be > 0
      expect(subject.payload.day_return).to be > 0
      expect(subject.payload.day_return_percent).to be > 0
      expect(subject.payload.total_return).to be > 0
      expect(subject.payload.total_return_percent).to be > 0
    end
    describe 'bad token' do
      let(:token) { 'foooooobaaarrrr' }
      it 'throws error' do
        expect { subject }.to raise_error(TradeIt::Errors::LoginException)
      end
    end
  end

end
