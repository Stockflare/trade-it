require 'spec_helper'

describe TradeIt::Order::Cancel do
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

  describe 'Cancel Order' do
    let(:orders) do
      TradeIt::Order::Status.new(
        token: token,
        account_number: account_number
      ).call.response.payload.orders
    end
    let(:order_number) { orders[1].order_number }

    subject do
      TradeIt::Order::Cancel.new(
        token: token,
        account_number: account_number,
        order_number: order_number
      ).call.response
    end

    it 'returns details' do
      expect(subject.status).to eql 200
      expect(subject.payload.type).to eql 'success'
      expect(subject.payload.token).not_to be_empty
      expect(subject.payload.orders[0].ticker).to eql 'ftfy'
      expect(subject.payload.orders[0].order_action).to eql :buy
      expect(subject.payload.orders[0].filled_quantity).to eql 0.0
      expect(subject.payload.orders[0].filled_price).to eql 0.0
      expect(subject.payload.orders[0].quantity).to eql 275_000
      expect(subject.payload.orders[0].expiration).to eql :gtc
    end
  end
end
