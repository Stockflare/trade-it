require 'spec_helper'

describe TradeIt::User::OauthUrlMobile do
  let(:broker) { :dummy }

  subject do
    TradeIt::User::OauthUrlMobile.new(
      broker: broker,
      callback_url: 'https://stockflare.com/stock/aapl.o'
    ).call.response
  end

  describe 'good broker' do
    it 'returns url' do
      puts subject.inspect
      expect(subject.status).to eql 200
      expect(subject.payload.type).to eql 'success'
      expect(subject.payload.url).not_to be_empty
    end
  end

  describe 'bad credentials' do
    let(:broker) { 'foooooobaaarrrr' }
    it 'throws error' do
      expect { subject }.to raise_error(Trading::Errors::LoginException)
    end
  end
end
