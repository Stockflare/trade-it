require 'spec_helper'

describe TradeIt::User::Login do
  let(:username) { 'dummy' }
  let(:password) { 'pass' }
  let(:broker) { :dummy }
  let!(:link) do
    TradeIt::User::Link.new(
      username: username,
      password: password,
      broker: broker
    ).call.response
  end
  let(:user_id) { link.payload.user_id }
  let(:user_token) { link.payload.user_token }

  subject do
    TradeIt::User::Login.new(
      user_id: user_id,
      user_token: user_token
    ).call.response
  end

  describe 'good credentials' do
    it 'returns token' do
      expect(subject.status).to eql 200
      expect(subject.payload.type).to eql 'success'
      expect(subject.payload.token).not_to be_empty
    end
  end

  describe 'bad credentials' do
    let(:user_id) { 'foooooobaaarrrr' }
    it 'throws error' do
      expect { subject }.to raise_error(Trading::Errors::LoginException)
    end
  end

  describe 'user needing security question' do
    let(:username) { 'dummySecurity' }
    it 'returns response with questions' do
      expect(subject.payload.type).to eql 'verify'
      expect(subject.payload.challenge).to eql 'question'
      expect(subject.payload.data).to have_key :answers
    end

    describe 'image' do
      let(:username) { 'dummySecurityImage' }
      it 'returns image in response' do
        expect(subject.payload.data.encoded).not_to be_empty
      end
    end
  end
end
